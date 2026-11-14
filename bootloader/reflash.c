/*
 * reflash.c - Bootloader command handlers (the reflash / service protocol)
 *             Full reconstruction of the handlers at
 *             0xF77E, 0xF7E4, 0xF832, 0xF8BD, 0xF948, 0xF94C, 0xF9C9,
 *             0xFA5B, 0xFAB4 and 0xFABE.
 *
 * See protocol.md for the wire format.  Each handler is a small state
 * machine re-entered once per received byte; it uses three shared RAM
 * variables and a shared frame buffer:
 *
 *     g_cmdState  (0x0218)   current sub-state, 0 = new command
 *     g_cmdIndex  (0x0219)   byte index within the current field
 *     g_frame[]   (0x021A)   the frame data buffer (TX from / RX into)
 *
 * and the two parameter cells that overlay the start of the buffer:
 *     g_addr = g_frame[0]:g_frame[1]   (0x021A:0x021B) big-endian address
 *     g_len  = g_frame[2]              (0x021C)        byte count
 *     g_tmp  = g_frame[3]              (0x021D)        scratch / blank-check
 *
 * A handler returns 0 when the command is finished (the main loop then
 * resets the parser) and non-zero while it still expects more bytes.
 *
 * TWO downloaded RAM code slots are used (the actual flash erase/program
 * routine is never in flash — see protocol.md):
 *     0x01A0   staged by 'D', executed by 'E'
 *     0x0100   staged by 'F', executed by the 'L'/write-mode body
 *
 * The SCI block send (Boot_SciSend) corresponds to the asm helpers
 * Boot_SciPutHex (0xFCC4) / Boot_SciPutc (0xFC67): both stream a block of
 * raw bytes from a buffer into the TX FIFO and return the number sent.
 */
#include "mc9s08aw32.h"

#define R8(a)       (*(volatile byte *)(a))
#define g_cmdState  R8(0x0218)
#define g_cmdIndex  R8(0x0219)
#define FRAME       ((volatile byte *)0x021A)     /* g_frame[0..] */
#define g_frameFlag R8(0x009C)                    /* "complete frame received" */

/* result/record cells set by the download handlers */
#define g_rec0  R8(0x01F0)
#define g_rec1  R8(0x01F2)
#define g_rec2  R8(0x01F4)
#define g_rec3  R8(0x01F5)
#define g_mode  R8(0x0217)                        /* W clears, L sets */

typedef void (*RamRoutine)(void);
#define RUN_RAM_A()   (((RamRoutine)0x01A0)())
#define RUN_RAM_B()   (((RamRoutine)0x0100)())

extern byte Boot_SciSend(const volatile byte *buf, byte count);  /* 0xFCC4/0xFC67 */
extern void Boot_MemCopy(byte *dst, byte *src, byte len);        /* 0xF759 */

#define ACK_BYTE  0x5D                            /* ']' completion marker */
#define BLANK     0x83                            /* erased flash byte (SWI) */

/* ======================================================================
 * Cmd_I  [0xF7E4]  Identify
 * Stage the 22-byte identity block from ROM 0xFE5E into the frame buffer,
 * patch in the live device id (SDIDH), then stream it out.
 * ====================================================================== */
byte Cmd_I(void)
{
    if (g_cmdState == 0) {
        g_cmdState = 1;
        g_cmdIndex = 0;
        Boot_MemCopy((byte *)FRAME, (byte *)0xFE5E, 0x16);
        FRAME[1] = SDIDH;                          /* 0x021B = live chip id hi */
    }
    /* send the 22-byte block, byte by byte */
    g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x16 - g_cmdIndex));
    if (g_cmdIndex == 0x16) {
        return 0;                                  /* done */
    }
    return 1;
}

/* ======================================================================
 * Cmd_D  [0xF832]  Download routine (>= 0x51 bytes) into RAM slot 0x01A0
 * ====================================================================== */
byte Cmd_D(void)
{
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1;
        g_cmdIndex = 0;
        break;
    case 1:                                        /* send 1 echo/length byte */
        g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x01 - g_cmdIndex));
        if (--g_cmdIndex == 0) {                    /* dbnza: one byte sent */
            g_cmdState = 2;
            g_cmdIndex = 0;
        }
        break;
    case 2:                                        /* receive the data block */
        g_cmdIndex += Boot_SciSend(&FRAME[1 + g_cmdIndex], (byte)(FRAME[0] - g_cmdIndex));
        if (FRAME[1] == FRAME[0]) {                /* all bytes in */
            if (FRAME[1] >= 0x51) {                 /* minimum length check */
                Boot_MemCopy((byte *)0x01A0, (byte *)&FRAME[1], FRAME[0]);
                g_rec0 = 0x01; g_rec1 = 0xA0;       /* record exec addr 0x01A0 */
                g_rec2 = 0x01; g_rec3 = 0xA0;
            }
        }
        break;
    }
    return g_cmdState != 0;                         /* loop until reset */
}

/* ======================================================================
 * Cmd_F  [0xF8BD]  Download large block (>= 0xA1 bytes) into RAM slot 0x0100
 * On completion it records exec address 0x0100 and ACKs with 0x5D.
 * ====================================================================== */
byte Cmd_F(void)
{
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1;
        g_cmdIndex = 0;
        break;
    case 1:
        g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x1A - g_cmdIndex));
        if (--g_cmdIndex == 0) {
            g_cmdState = 2;
            FRAME[0] = 0;
        }
        break;
    case 2:
        g_cmdIndex += Boot_SciSend(&FRAME[1 + g_cmdIndex], (byte)(FRAME[0] - g_cmdIndex));
        if (FRAME[1] == FRAME[0] && FRAME[1] >= 0xA1) {
            Boot_MemCopy((byte *)0x0100, (byte *)&FRAME[1], 0x01);
            g_rec1 = 0x01; R8(0x01F3) = 0x00;       /* 0x01F2:F3 = 0x0100 */
            g_rec2 = 0x01; g_rec3 = 0x00;           /* 0x01F4:F5 = 0x0100 */
            { byte a = ACK_BYTE; Boot_SciSend((volatile byte *)&a, 1); }
        }
        break;
    }
    return g_cmdState != 0;
}

/* ======================================================================
 * Cmd_Q  [0xF948]  Quit / no-op  (returns 1)
 * ====================================================================== */
byte Cmd_Q(void)
{
    return 1;
}

/* ======================================================================
 * Cmd_R  [0xF94C]  Read memory
 * Phase 1 sends a 3-byte echo (addr/len setup), then phase 3 streams
 * g_len bytes read from [g_addr .. g_addr+g_len-1].
 * ====================================================================== */
byte Cmd_R(void)
{
    word addr;
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1;
        g_cmdIndex = 0;
        break;
    case 1:                                        /* 3-byte setup echo */
        g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x03 - g_cmdIndex));
        if (g_cmdIndex == 0x03) {
            g_cmdState = 0;
            FRAME[0] = 0;
            if (R8(0x021A) == 0 && g_rec2 != 0) {   /* default address */
                R8(0x021A) = g_rec2; R8(0x021B) = g_rec3;
            }
            g_rec2 = 0; g_rec3 = 0;
            g_cmdState = 3;                         /* fallthrough intent */
        }
        break;
    case 3:                                        /* stream the data out */
        addr = (word)((R8(0x021A) << 8) | R8(0x021B));
        g_cmdIndex += Boot_SciSend((volatile byte *)(addr + g_cmdIndex),
                                   (byte)(R8(0x021C) - g_cmdIndex));
        if (FRAME[3] == R8(0x021C)) {              /* all requested bytes sent */
            return 0;
        }
        break;
    }
    return 1;
}

/* ======================================================================
 * Cmd_C  [0xF9C9]  Check / blank-check
 * Phase 1 sends a 3-byte echo; phase 2 reads one byte at g_addr+index and
 * reports whether it equals 0x83 (erased); phase 3 streams the index.
 * ====================================================================== */
byte Cmd_C(void)
{
    word addr;
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1;
        break;
    case 1:
        g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x03 - g_cmdIndex));
        if (g_cmdIndex == 0x03) {
            g_cmdState = 2;
            FRAME[2] = 0x02 - 1;                    /* deca: set loop marker */
            FRAME[0] = 0;
        }
        break;
    case 2:                                        /* blank-check one byte */
        addr = (word)((R8(0x021A) << 8) | R8(0x021B));
        FRAME[3] = (byte)((*(volatile byte *)(addr + g_cmdIndex) == BLANK) ? 1 : 0);
        g_cmdIndex++;
        if (FRAME[4] == 0 || FRAME[3] == FRAME[0]) {
            g_cmdIndex = 1;
            g_cmdState = 3;
        }
        break;
    case 3:
        { byte idx = g_cmdIndex;
          if (Boot_SciSend(&FRAME[3], 1) == 1) {   /* send the result byte */
              /* done */
          }
          g_cmdIndex = 0;
          (void)idx;
        }
        return 0;
    }
    return 1;
}

/* ======================================================================
 * Cmd_V  [0xFA5B]  Vectors / version
 * Stages the CPU vector table (0xFFC0, 0x1A bytes) and the application
 * version area (0x8604, 0x1E bytes) into the frame buffer, then sends 8
 * bytes out.
 * ====================================================================== */
byte Cmd_V(void)
{
    if (g_cmdState == 0) {
        g_cmdState = 1;
        g_cmdIndex = 0;
        Boot_MemCopy((byte *)FRAME,        (byte *)0xFFC0, 0x1A);
        Boot_MemCopy((byte *)&FRAME[4],    (byte *)0x8604, 0x1E);
    }
    g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x08 - g_cmdIndex));
    if (g_cmdIndex == 0x08) {
        return 0;
    }
    return 1;
}

/* ======================================================================
 * Cmd_W  [0xFAB4]  Write mode  (clear the mode flag, then common body)
 * Cmd_L  [0xFABE]  Lock mode   (set the mode flag, then common body)
 *
 * The common body (0xFACA) sends a 3-byte echo, then:
 *   - in write mode (g_mode == 0): it fills the frame with 0x83 and, once
 *     g_len bytes are collected, writes the 0x55 "programmed" marker into
 *     the target page (0x7C1D + offset) for addresses >= 0x8601, i.e. it
 *     arms the program of a flash page via the downloaded routine;
 *   - in lock/verify mode (g_mode != 0): when a full frame is present
 *     (0x009C == 1) it calls the downloaded routine at 0x0100
 *     (RUN_RAM_B) with g_addr/g_len and ACKs with 0x5D.
 * ====================================================================== */
static byte Cmd_WL_body(void)
{
    word addr;

    if (g_cmdState == 0) {
        g_cmdState = 1;
        g_cmdIndex = 0;
        return 1;
    }
    if (g_cmdState == 1) {                          /* 3-byte echo */
        g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x03 - g_cmdIndex));
        if (g_cmdIndex == 0x03) {
            g_cmdState = 2;
            FRAME[0] = 0;
        }
        return 1;
    }
    if (g_cmdState == 2) {                          /* collect / mark */
        if (g_mode == 0) {                          /* write mode: fill 0x83 */
            FRAME[3 + g_cmdIndex] = BLANK;          /* 0x021D[idx] = 0x83 */
            g_cmdIndex++;
        } else {                                    /* verify mode: echo */
            g_cmdIndex += Boot_SciSend(&FRAME[3 + g_cmdIndex],
                                       (byte)(R8(0x021C) - g_cmdIndex));
        }
        if (R8(0x021C) == g_cmdIndex) {             /* field complete */
            if (g_rec1 == 0 && R8(0x01F3) == 0) {   /* no staged routine */
                return 0;
            }
            g_cmdState = 3;
            addr = (word)((R8(0x021A) << 8) | R8(0x021B));
            if (addr >= 0x8601 &&
                (word)(addr + R8(0x021C)) <= 0x8600 + 0x100) {
                /* arm the page: write the 0x55 marker into the staging area */
                *(volatile byte *)(0x7C1D + R8(0x021A)) = 0x55;
            }
        }
        return 1;
    }
    /* g_cmdState == 3: run the downloaded programmer and ACK */
    if (g_frameFlag == 1) {
        addr = (word)((R8(0x021A) << 8) | R8(0x021B));
        (void)addr;
        RUN_RAM_B();                                /* jsr 0x0100 */
        { byte a = ACK_BYTE; Boot_SciSend((volatile byte *)&a, 1); }
    }
    return 0;
}

byte Cmd_W(void)
{
    if (g_cmdState == 0) {
        g_mode = 0;                                 /* write / unlocked */
    }
    return Cmd_WL_body();
}

byte Cmd_L(void)
{
    if (g_cmdState == 0) {
        g_mode = 1;                                 /* lock / verify */
    }
    return Cmd_WL_body();
}

/* ======================================================================
 * Cmd_E  [0xF77E]  Execute the routine staged by 'D' (RAM slot 0x01A0)
 * Sends a 2-byte status, and once a complete frame carrying the address is
 * present (g_frameFlag == 1) jumps to the downloaded routine, then ACKs.
 * ====================================================================== */
byte Cmd_E(void)
{
    switch (g_cmdState) {
    case 0:
        g_cmdState = 1;
        g_cmdIndex = 0;
        break;
    case 1:                                        /* 2-byte status */
        g_cmdIndex += Boot_SciSend(&FRAME[g_cmdIndex], (byte)(0x02 - g_cmdIndex));
        if (g_cmdIndex == 0x02) {
            g_cmdState = 2;
            if (g_rec0 == 0 && R8(0x01F1) == 0) {
                /* no routine staged: nothing to run */
            }
        }
        break;
    case 2:
        if (g_frameFlag == 1) {
            RUN_RAM_A();                            /* jsr 0x01A0 */
            { byte a = ACK_BYTE; Boot_SciSend((volatile byte *)&a, 1); }
        }
        break;
    }
    return g_cmdState != 0;
}
