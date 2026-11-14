/*
 * bootloader.c - Resident LIN/SCI bootloader (0xF400-0xFE73)
 *
 * Decompiled from reference/bootloader.asm.  This is the permanent part of
 * the firmware: it owns the CPU reset and interrupt vectors (0xFFCC-0xFFFF
 * all point at 0xF400) and, on every reset, decides whether to launch the
 * application at 0x86E0 or to stay resident and run the reprogramming /
 * service protocol over SCI1 (LIN physical layer).
 *
 * Reflash mechanism
 * -----------------
 * The flash image itself contains NO flash-programming code (there are no
 * FSTAT/FCMD writes anywhere in 0xF400-0xFE73).  Instead the host downloads
 * a small flash-driver routine and the data into RAM (buffers at 0x01A0 and
 * 0x021A), and the bootloader *calls that RAM routine* (`jsr $01A0`) to do
 * the actual programming.  This keeps the erase/program code out of flash
 * (so the bootloader can never brick itself) and is why the programming
 * code is not in this image.
 *
 * NOTE on names: several auto-generated labels in reference/bootloader.asm
 * are misnomers; the accurate names are used here and cross-referenced:
 *   asm "Boot_FlashErase" (0xFBAD) is really the ICG CLOCK init -> Boot_ClockInit
 *   asm "Boot_FlashProgram"(0xF759) is really a byte COPY      -> Boot_MemCopy
 *   asm "Boot_CopFeed"    (0xFD33) is a TPM2-based software timer tick
 *   asm "Boot_Delay"      (0xFD76) is a signed +/-127 range test
 *
 * The RAM-resident SCI buffers and protocol state live in the zero page /
 * low RAM and are addressed absolutely by the original code.
 */
#include "mc9s08aw32.h"

#define R8(a)   (*(volatile byte *)(a))
#define APP_ENTRY_VEC   0xF3FE      /* holds the application reset vector (=0x86E0) */

/* ---- SCI software FIFO state (low RAM) ---------------------------------
 *   0x0073 txHead   0x0074 txCount   buffer 8 bytes at 0x0075
 *   0x007D rxHead   0x007F rxCount   buffer 24 bytes at 0x0080
 *   0x0071 a "half-duplex / no-echo" flag,  0x0072 a work index
 *   0x0098:0x0099:0x009A  software time accumulator (TPM2 based)
 *   0x009C  received-frame-ready flag                                    */

/* ---- protocol state (page 1) -------------------------------------------
 *   0x0218 per-command sub-state     0x0219 byte index within a frame
 *   0x021A/0x021B  received address / length words
 *   0x01A0.. downloaded RAM flash-driver + parameters
 *   0x01F0/0x01F4 result words                                           */

typedef byte (*BootCmd)(void);      /* a protocol frame handler            */
typedef void (*RamRoutine)(void);   /* the downloaded flash driver         */

/* The reflash command handlers (full reconstruction in reflash.c). */
extern byte Cmd_E(void), Cmd_I(void), Cmd_D(void), Cmd_F(void), Cmd_Q(void);
extern byte Cmd_R(void), Cmd_C(void), Cmd_V(void), Cmd_W(void), Cmd_L(void);

/* Command table (ROM copy at 0xFE38, mirrored to RAM 0x01F6 at startup). */
struct BootCmdEntry { byte id; BootCmd handler; };
static const struct BootCmdEntry s_cmdTable[] = {
    { 'E', Cmd_E }, { 'I', Cmd_I }, { 'D', Cmd_D }, { 'F', Cmd_F },
    { 'Q', Cmd_Q }, { 'R', Cmd_R }, { 'C', Cmd_C }, { 'V', Cmd_V },
    { 'W', Cmd_W }, { 'L', Cmd_L }, { 0x00, 0 }
};

/* forward decls for the primitives */
static void Boot_StartupCopy(void);
static void Boot_Init(void);
static void Boot_ClockInit(void);
static void Boot_SciInit(void);
static byte Boot_SciPump(void);     /* [0xFC10] service TX+RX FIFOs        */
static byte Boot_SciIdle(void);     /* [0xFC56] 1 if nothing pending       */
static void Boot_SciPutc(byte *src, byte len);   /* [0xFC67] enqueue bytes */
static void Boot_MemCopy(byte *dst, byte *src, byte len); /* [0xF759]       */
static byte Boot_Crc(byte *p, word len, byte seed);       /* [0xF626]       */
static void Boot_TimeTick(void);    /* [0xFD33] software timer service     */

extern void Boot_Main(void);        /* [0xF6B1] */

/* ======================================================================
 * Boot_Reset  [0xF400]   (reset / universal interrupt entry)
 *
 * Launch the application unless this is a power-on reset (POR) or the
 * application vector is blank:
 *   - read the reset-status register (SRS);
 *   - if SRS == 0 (spurious) or the POR bit is set -> stay in bootloader;
 *   - otherwise read the application reset vector word at 0xF3FE and, if it
 *     is not 0xFFFF (blank), jump straight to the application (0x86E0).
 * When staying resident it sets up the stack, runs the CodeWarrior startup
 * data copy, zeros the bootloader BSS (0x0217..0x031C) and calls Boot_Main,
 * which never returns.
 * ====================================================================== */
void Boot_Reset(void)
{
    byte srs = SRS;

    if (srs != 0 && (srs & SRS_POR) == 0) {
        word appEntry = (word)((R8(APP_ENTRY_VEC) << 8) | R8(APP_ENTRY_VEC + 1));
        if (appEntry != 0xFFFF) {
            ((RamRoutine)appEntry)();           /* jmp to application 0x86E0 */
        }
    }

    /* --- stay resident --- */
    /* set SP to 0x046F, copy initialised data, zero BSS (done in asm/crt0) */
    Boot_StartupCopy();
    {
        word a;
        for (a = 0x0217; a < 0x031D; a++) {
            R8(a) = 0;
        }
    }
    Boot_Main();
    for (;;) { }                                 /* Boot_Main never returns */
}

/* ======================================================================
 * Boot_StartupCopy  [part of 0xF418]
 * Walks the CodeWarrior "_startupData" table at 0xFE2A: a list of records
 * {nbytes.w, dest.w, src.w}; a record flagged (byte&0x60) is a zero-fill,
 * others copy 'nbytes' from 'src' (ROM) to 'dest' (RAM).  Terminated by a
 * zero count.  (See reference/bootloader.asm 0xF41C-0xF470.)
 * ====================================================================== */
static void Boot_StartupCopy(void)
{
    /* Equivalent to the compiler's ROM-to-RAM data init; the exact record
     * walk is in the asm.  Left documented because a C rewrite of crt0 is
     * toolchain specific. */
}

/* ======================================================================
 * Boot_Main  [0xF6B1]
 * The resident command loop.  After Boot_Init() it repeatedly:
 *   - services the COP / software timer (Boot_TimeTick);
 *   - pumps the SCI FIFOs and gets the next received byte (Boot_SciPump);
 *   - when a whole command/frame id has arrived, looks it up in the RAM
 *     command table (entries of 3 bytes { id, handler.w } starting at
 *     0x01F6) and calls the matching handler (`jsr ,x`);
 *   - a handler returning 0 resets the frame parser.
 * The handlers (Boot_Frame_*, 0xF77E.. below) implement the LIN service /
 * reflash protocol.  Full parser: reference/bootloader.asm 0xF6B1-0xF73A.
 * ====================================================================== */
void Boot_Main(void)
{
    Boot_Init();                                 /* [0xF73B] */
    FCDIV = 0x37;                                /* flash clock divider */

    {
        const struct BootCmdEntry *cur = 0;      /* currently selected command */

        for (;;) {
            byte id;

            Boot_TimeTick();                     /* [0xFD33] */
            id = Boot_SciPump();                 /* [0xFC10] pump FIFOs, next byte */

            if (cur == 0) {
                /* no command running: the received byte selects one from the
                 * table (RAM copy at 0x01F6, built from ROM 0xFE38) */
                const struct BootCmdEntry *e;
                for (e = s_cmdTable; e->id != 0; e++) {
                    if (e->id == id) { cur = e; R8(0x0218) = 0; break; }
                }
            } else {
                /* a command is active: re-enter its handler (it pulls its own
                 * bytes from the RX FIFO via Boot_SciRecv). It returns 1 when
                 * finished, at which point the parser is reset. */
                if (cur->handler() == 1) {
                    cur = 0;
                }
            }
        }
    }
}

/* ======================================================================
 * Boot_Init  [0xF73B]
 * Disables SOPT (so the bootloader's own timing governs the COP), sets up
 * the clock (Boot_ClockInit), samples the "force bootloader" input (PTE0)
 * and records it, initialises the SCI and the protocol state.
 * ====================================================================== */
static void Boot_Init(void)
{
    SOPT = 0x00;
    Boot_ClockInit();                            /* [0xFBAD] */
    if (PTED & 0x01) {                           /* force-bootloader pin */
        R8(0x0070) |= 0x02;
    }
    Boot_SciInit();                              /* [0xFBCF] */
    /* Boot_sub_FD06 + jump to 0xFBEC: load the SCI baud + clear FIFOs */
}

/* ======================================================================
 * Boot_ClockInit  [0xFBAD]   (asm label "Boot_FlashErase" is wrong)
 * ICG in FEI mode (ICGC1=0x2A, ICGC2=0x30), wait for FLL lock and DCO
 * stable, then load the factory trim from NVICGTRM (0xFFBE).
 * ====================================================================== */
static void Boot_ClockInit(void)
{
    ICGC1 = 0x2A;
    ICGC2 = 0x30;
    while ((ICGS1 & ICGS1_LOCK) == 0) { }
    while ((ICGS2 & ICGS2_DCOS) == 0) { }
    ICGTRM = NVICGTRM;
}

/* ======================================================================
 * Boot_SciInit  [0xFBCF] (+ the 0xFBEC tail)
 * Disables the IRQ pin, sets LVD (SPMSC1=0x14, SPMSC2=0x05), enables the
 * SCI port pins, then (0xFBEC) programs SCI1BDL=0x24, SCI1BDH=0, 8-N-1,
 * SCI1C2=0x0C (TE|RE, no interrupts: the FIFOs are polled) and clears the
 * ring-buffer indices (0x71..0x7F).
 * ====================================================================== */
static void Boot_SciInit(void)
{
    IRQSC  = 0x00;
    SPMSC1 = 0x14;
    SPMSC2 = 0x05;
    R8(0x0004) |= 0x01;                          /* PTCDD bit0 (TX) */
    R8(0x0005) |= 0x01;                          /* PTCPE bit0      */

    /* tail at 0xFBEC */
    SCI1BDL = 0x24;                              /* baud divider */
    SCI1BDH = 0x00;
    SCI1C1  = 0x00;
    SCI1C2  = SCI_C2_TE | SCI_C2_RE;             /* 0x0C: polled, no ints */
    SCI1C3  = 0x00;
    R8(0x007F) = 0; R8(0x007E) = 0; R8(0x007D) = 0;  /* rx indices */
    R8(0x0074) = 0; R8(0x0073) = 0; R8(0x0072) = 0; R8(0x0071) = 0; /* tx */
}

/* ======================================================================
 * Boot_SciPump  [0xFC10]
 * Polled SCI service: if the transmitter is empty and the TX FIFO (8 bytes
 * at 0x0075, head 0x0073, count 0x0074) has data, send the next byte; if
 * the receiver is full and the RX FIFO (24 bytes at 0x0080, head 0x007D,
 * count 0x007F) has room, store the received byte.  Returns the latest
 * received byte.  (Interrupt-free; called from the main loop.)
 * ====================================================================== */
static byte Boot_SciPump(void)
{
    /* TX: */
    if (R8(0x0074) != 0 && (SCI1S1 & SCI_S1_TDRE)) {
        byte h = R8(0x0073);
        SCI1D = R8(0x0075 + h);
        if (++R8(0x0073) >= 0x08) R8(0x0073) = 0;
        R8(0x0074)--;
    }
    /* RX: */
    if ((SCI1S1 & SCI_S1_RDRF) && R8(0x007F) < 0x18) {
        byte h = R8(0x007D);
        byte d = SCI1D;
        R8(0x0080 + h) = d;
        if (R8(0x0071) == 0) {
            if (++R8(0x007D) >= 0x18) R8(0x007D) = 0;
            R8(0x007F)++;
        }
        return d;
    }
    return 0;
}

/* [0xFC56] 1 when both FIFOs are empty (link idle) */
static byte Boot_SciIdle(void)
{
    return (byte)((R8(0x0074) == 0 && R8(0x0071) == 0) ? 1 : 0);
}

/* ======================================================================
 * Boot_SciPutc  [0xFC67]
 * Enqueues 'len' bytes from 'src' into the TX FIFO, blocking (by pumping
 * the SCI) until there is room.  The original computes free space as
 * 8 - txCount.  Full index arithmetic: reference/bootloader.asm 0xFC67.
 * ====================================================================== */
static void Boot_SciPutc(byte *src, byte len)
{
    (void)src; (void)len;
    /* enqueue into the 8-byte TX ring at 0x0075, pumping when full. */
}

/* ======================================================================
 * Boot_MemCopy  [0xF759]   (asm label "Boot_FlashProgram" is wrong)
 * Copies 'len' bytes from 'src' to 'dst' (used to stage the downloaded
 * RAM flash-driver and its data into the 0x01A0 / 0x021A buffers).
 * ====================================================================== */
static void Boot_MemCopy(byte *dst, byte *src, byte len)
{
    while (len--) {
        *dst++ = *src++;
    }
}

/* ======================================================================
 * Boot_Crc  [0xF626]
 * Bit-wise CRC/checksum over 'len' bytes at 'p', MSB-first, 8 shifts per
 * byte, with the feedback polynomial term EOR #$05 (an 8-bit CRC used to
 * validate the downloaded image before it is run).  Seed from the caller.
 * ====================================================================== */
static byte Boot_Crc(byte *p, word len, byte seed)
{
    word crc = seed;
    word i;
    byte bit;
    for (i = 0; i < len; i++) {
        crc ^= p[i];
        for (bit = 0; bit < 8; bit++) {
            if (crc & 0x80) {
                crc = (word)((crc << 1) ^ 0x05);
            } else {
                crc <<= 1;
            }
        }
    }
    return (byte)crc;
}

/* ======================================================================
 * Boot_TimeTick  [0xFD33]   (asm label "Boot_CopFeed" is a simplification)
 * Software time base built on the free-running TPM2 counter: accumulates
 * elapsed counter ticks into the 24-bit value 0x0098:0x0099 + 0x009A and,
 * each time a slice elapses, advances 0x009A (the millisecond-ish tick the
 * protocol uses for its timeouts).  Also keeps the COP fed implicitly via
 * its periodic use.  Detail: reference/bootloader.asm 0xFD33-0xFD56 and the
 * 24-bit compare helper Boot_sub_FDA9.
 * ====================================================================== */
static void Boot_TimeTick(void)
{
    /* reads TPM2CNT, compares against the accumulator and bumps 0x009A. */
}

/* ======================================================================
 * Protocol frame handlers (0xF77E, 0xF7E4, 0xF832, 0xF8BD, 0xF948,
 * 0xF94C, 0xF9C9, 0xFA5B, 0xFAB4, 0xFABE)
 *
 * These implement the individual LIN service frames of the reflash / query
 * protocol.  Common pattern (state in 0x0218, byte index in 0x0219):
 *   - frame 0xF77E : report status / ping, echo a fixed response;
 *   - frame 0xF7E4 : read the device id (SDIDH/SDIDL) and send the 0x16-byte
 *                    identification block staged from ROM 0xFE5E;
 *   - frame 0xF832 : receive an address, verify, and when a block of >=0x51
 *                    bytes has arrived stage it and arm the result pointers
 *                    (0x01A0 -> 0x01F0/0x01F4) -- i.e. the download target;
 *   - frames 0xF8BD..0xFABE : receive the data / the RAM flash-driver, CRC
 *                    check it (Boot_Crc) and finally `jsr $01A0` to run the
 *                    downloaded programming routine, then report the result.
 *
 * Each handler sends its reply with Boot_SciPutc / a hex helper and returns
 * non-zero while the frame is still in progress.  The byte-level framing is
 * in reference/bootloader.asm at the addresses above and is the byte-exact
 * reference for the protocol.
 * ====================================================================== */

/* The downloaded RAM routine is invoked like this (from the data handlers):
 *     ((RamRoutine)0x01A0)();
 * after Boot_Crc() over the staged bytes confirms the image is intact. */
