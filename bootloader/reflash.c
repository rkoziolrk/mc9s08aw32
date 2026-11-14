/*
 * reflash.c - Bootloader command handlers (the reflash / service protocol)
 *             Full reconstruction of the handlers at
 *             0xF77E, 0xF7E4, 0xF832, 0xF8BD, 0xF948, 0xF94C, 0xF9C9,
 *             0xFA5B, 0xFAB4 and 0xFABE.  See protocol.md for the wire
 *             format.
 *
 * Verified against reference/bootloader.asm.  Two things that are easy to
 * get backwards and were checked explicitly:
 *
 *  1. The two SCI primitives (names in the asm are misleading):
 *       Boot_SciRecv  (asm "Boot_SciPutHex", 0xFCC4)
 *            copies bytes FROM the RX FIFO (0x0080) INTO a buffer,
 *            returns the number received (0 if none waiting).
 *       Boot_SciSend  (asm "Boot_SciPutc",   0xFC67)
 *            copies bytes FROM a buffer INTO the TX FIFO (0x0075),
 *            returns the number queued.
 *
 *  2. Completion convention: the main loop does `jsr handler; dbnza loop`,
 *     so a handler RETURNS 1 WHEN FINISHED (the parser then resets) and
 *     returns 0 (or any non-1 value) to stay active and be re-entered on
 *     the next byte.
 *
 * Shared state:
 *     g_cmdState (0x0218)  sub-state, 0 = new command
 *     g_cmdIndex (0x0219)  byte index within the current field
 *     FRAME[]    (0x021A)  frame buffer; FRAME[0..1]=address, FRAME[2]=len,
 *                          FRAME[3]=scratch
 * Two downloaded RAM code slots (the flash erase/program code is never in
 * flash): 0x01A0 (staged by 'D', run by 'E') and 0x0100 (staged by 'F',
 * run by the 'W'/'L' body).
 */
#include "mc9s08aw32.h"

#define R8(a)       (*(volatile byte *)(a))
#define g_cmdState  R8(0x0218)
#define g_cmdIndex  R8(0x0219)
#define FRAME       ((volatile byte *)0x021A)
#define g_frameFlag R8(0x009C)

#define g_rec0  R8(0x01F0)
#define g_rec2  R8(0x01F4)
#define g_rec3  R8(0x01F5)
#define g_mode  R8(0x0217)

typedef void (*RamRoutine)(void);
#define RUN_RAM_A()   (((RamRoutine)0x01A0)())     /* 'E' */
#define RUN_RAM_B()   (((RamRoutine)0x0100)())     /* 'W'/'L' */

extern byte Boot_SciRecv(volatile byte *dst, byte max);        /* 0xFCC4 */
extern byte Boot_SciSend(const volatile byte *src, byte count);/* 0xFC67 */
extern void Boot_MemCopy(byte *dst, byte *src, byte len);      /* 0xF759 */

#define DONE      1
#define CONTINUE  0
#define ACK_BYTE  0x5D        /* ']' completion marker */
#define BLANK     0x83        /* erased flash byte (SWI opcode) */

/* ======================================================================
 * Cmd_I  [0xF7E4]  Identify  -- SENDS the 22-byte identity block
 * ====================================================================== */
byte Cmd_I(void)
{
    if (g_cmdState == 0) {
        g_cmdState = 1;
        g_cmdIndex = 0;
        Boot_MemCopy((byte *)FRAME, (byte *)0xFE5E, 0x16);
        FRAME[1] = SDIDH;                      /* live chip id high byte */
    }
    g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x16 - g_cmdIndex));
    return (g_cmdIndex == 0x16) ? DONE : CONTINUE;
}

/* ======================================================================
 * Cmd_D  [0xF832]  Download routine -- RECEIVES length + data -> 0x01A0
 * ====================================================================== */
byte Cmd_D(void)
{
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1; g_cmdIndex = 0;
        return CONTINUE;
    case 1:                                     /* receive the 1-byte length */
        g_cmdIndex += Boot_SciRecv(&FRAME[0], (byte)(1 - g_cmdIndex));
        if (g_cmdIndex == 1) { g_cmdState = 2; g_cmdIndex = 0; }
        return CONTINUE;
    default:                                    /* state 2: receive the data */
        g_cmdIndex += Boot_SciRecv(&FRAME[1 + g_cmdIndex],
                                   (byte)(FRAME[0] - g_cmdIndex));
        if (g_cmdIndex == FRAME[0]) {
            if (FRAME[0] >= 0x51) {             /* minimum length */
                Boot_MemCopy((byte *)0x01A0, (byte *)&FRAME[1], FRAME[0]);
                g_rec0 = 0x01; g_rec2 = 0x01; g_rec3 = 0xA0;  /* exec @0x01A0 */
            }
            return DONE;
        }
        return CONTINUE;
    }
}

/* ======================================================================
 * Cmd_F  [0xF8BD]  Download large block (>=0xA1) -> RAM slot 0x0100
 * ====================================================================== */
byte Cmd_F(void)
{
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1; g_cmdIndex = 0;
        return CONTINUE;
    case 1:
        g_cmdIndex += Boot_SciRecv(&FRAME[0], (byte)(0x1A - g_cmdIndex));
        if (g_cmdIndex == 0x1A) { g_cmdState = 2; g_cmdIndex = 0; }
        return CONTINUE;
    default:                                    /* state 2 */
        g_cmdIndex += Boot_SciRecv(&FRAME[1 + g_cmdIndex],
                                   (byte)(FRAME[0] - g_cmdIndex));
        if (g_cmdIndex == FRAME[0]) {
            if (FRAME[0] >= 0xA1) {
                Boot_MemCopy((byte *)0x0100, (byte *)&FRAME[1], FRAME[0]);
                R8(0x01F2) = 0x01; R8(0x01F3) = 0x00;   /* exec @0x0100 */
                g_rec2 = 0x01; g_rec3 = 0x00;
                { byte a = ACK_BYTE; Boot_SciSend(&a, 1); }
            }
            return DONE;
        }
        return CONTINUE;
    }
}

/* ======================================================================
 * Cmd_Q  [0xF948]  Quit / no-op -- returns DONE immediately
 * ====================================================================== */
byte Cmd_Q(void)
{
    return DONE;
}

/* ======================================================================
 * Cmd_R  [0xF94C]  Read memory
 * RECEIVES {addrHi, addrLo, len} (3 bytes), then SENDS 'len' bytes read
 * from that address.
 * ====================================================================== */
byte Cmd_R(void)
{
    word addr;
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1; g_cmdIndex = 0;
        return CONTINUE;
    case 1:                                     /* receive addr + length */
        g_cmdIndex += Boot_SciRecv(&FRAME[g_cmdIndex], (byte)(3 - g_cmdIndex));
        if (g_cmdIndex == 3) {
            if (FRAME[0] == 0 && g_rec2 != 0) { /* default address */
                FRAME[0] = g_rec2; FRAME[1] = g_rec3;
            }
            g_rec2 = 0; g_rec3 = 0;
            g_cmdState = 3; g_cmdIndex = 0;
        }
        return CONTINUE;
    default:                                    /* state 3: send the data */
        addr = (word)((FRAME[0] << 8) | FRAME[1]);
        g_cmdIndex += Boot_SciSend((volatile byte *)(addr + g_cmdIndex),
                                   (byte)(FRAME[2] - g_cmdIndex));
        return (g_cmdIndex == FRAME[2]) ? DONE : CONTINUE;
    }
}

/* ======================================================================
 * Cmd_C  [0xF9C9]  Blank-check
 * RECEIVES {addrHi, addrLo, len}, then for each byte reports whether the
 * flash content equals 0x83 (erased); SENDS the per-byte result.
 * ====================================================================== */
byte Cmd_C(void)
{
    word addr;
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1; g_cmdIndex = 0;
        return CONTINUE;
    case 1:                                     /* receive addr + length */
        g_cmdIndex += Boot_SciRecv(&FRAME[g_cmdIndex], (byte)(3 - g_cmdIndex));
        if (g_cmdIndex == 3) { g_cmdState = 2; g_cmdIndex = 0; }
        return CONTINUE;
    case 2:                                     /* blank-check one byte */
        addr = (word)((FRAME[0] << 8) | FRAME[1]);
        FRAME[3] = (byte)((*(volatile byte *)(addr + g_cmdIndex) == BLANK) ? 1 : 0);
        g_cmdIndex++;
        if (g_cmdIndex == FRAME[2]) { g_cmdState = 3; g_cmdIndex = 1; }
        return CONTINUE;
    default:                                    /* state 3: send result */
        if (Boot_SciSend(&FRAME[3], 1) == 1) {
            g_cmdIndex = 0;
            return DONE;
        }
        return CONTINUE;
    }
}

/* ======================================================================
 * Cmd_V  [0xFA5B]  Vectors / version -- SENDS 8 bytes
 * Stages the CPU vector table (0xFFC0, 0x1A bytes) and the application
 * version area (0x8604, 0x1E bytes) into the frame buffer first.
 * ====================================================================== */
byte Cmd_V(void)
{
    if (g_cmdState == 0) {
        g_cmdState = 1; g_cmdIndex = 0;
        Boot_MemCopy((byte *)FRAME,     (byte *)0xFFC0, 0x1A);
        Boot_MemCopy((byte *)&FRAME[4], (byte *)0x8604, 0x1E);
    }
    g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x08 - g_cmdIndex));
    return (g_cmdIndex == 0x08) ? DONE : CONTINUE;
}

/* ======================================================================
 * Cmd_W  [0xFAB4]  Write mode (g_mode = 0) + body
 * Cmd_L  [0xFABE]  Lock mode  (g_mode = 1) + body
 *
 * Body: RECEIVES {addrHi, addrLo, len}; in write mode fills the staging
 * buffer with 0x83 and, for a target page >= 0x8601, writes the 0x55
 * "program this page" marker; in verify mode it receives the data. When
 * complete it runs the downloaded programmer at 0x0100 and SENDS ACK 0x5D.
 * ====================================================================== */
static byte Cmd_WL_body(void)
{
    word addr;

    switch (g_cmdState) {
    case 0:
        g_cmdState = 1; g_cmdIndex = 0;
        return CONTINUE;
    case 1:                                     /* receive addr + length */
        g_cmdIndex += Boot_SciRecv(&FRAME[g_cmdIndex], (byte)(3 - g_cmdIndex));
        if (g_cmdIndex == 3) { g_cmdState = 2; g_cmdIndex = 0; }
        return CONTINUE;
    case 2:
        if (g_mode == 0) {                      /* write mode: fill 0x83 */
            FRAME[3 + g_cmdIndex] = BLANK;      /* 0x021D[idx] */
            g_cmdIndex++;
        } else {                                /* verify mode: receive */
            g_cmdIndex += Boot_SciRecv(&FRAME[3 + g_cmdIndex],
                                       (byte)(FRAME[2] - g_cmdIndex));
        }
        if (g_cmdIndex == FRAME[2]) {
            if (R8(0x01F2) == 0 && R8(0x01F3) == 0) {
                return DONE;                    /* no staged programmer */
            }
            g_cmdState = 3;
            addr = (word)((FRAME[0] << 8) | FRAME[1]);
            if (addr >= 0x8601 && (word)(addr + FRAME[2]) <= 0x8700) {
                *(volatile byte *)(0x7C1D + FRAME[0]) = 0x55;  /* page marker */
            }
        }
        return CONTINUE;
    default:                                    /* state 3: run + ACK */
        if (g_frameFlag == 1) {
            RUN_RAM_B();                         /* jsr 0x0100 (program flash) */
            { byte a = ACK_BYTE; Boot_SciSend(&a, 1); }
        }
        return DONE;
    }
}

byte Cmd_W(void)
{
    if (g_cmdState == 0) { g_mode = 0; }        /* write / unlocked */
    return Cmd_WL_body();
}

byte Cmd_L(void)
{
    if (g_cmdState == 0) { g_mode = 1; }        /* lock / verify */
    return Cmd_WL_body();
}

/* ======================================================================
 * Cmd_E  [0xF77E]  Execute the routine staged by 'D' (RAM slot 0x01A0)
 * RECEIVES the 2-byte address parameter, then jumps to the downloaded
 * routine and SENDS ACK 0x5D.
 * ====================================================================== */
byte Cmd_E(void)
{
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1; g_cmdIndex = 0;
        return CONTINUE;
    case 1:                                     /* receive 2-byte address */
        g_cmdIndex += Boot_SciRecv(&FRAME[g_cmdIndex], (byte)(2 - g_cmdIndex));
        if (g_cmdIndex == 2) { g_cmdState = 2; }
        return CONTINUE;
    default:                                    /* state 2: run + ACK */
        if (g_frameFlag == 1) {
            RUN_RAM_A();                         /* jsr 0x01A0 */
            { byte a = ACK_BYTE; Boot_SciSend(&a, 1); }
        }
        return DONE;
    }
}
