/*
 * nvm.c - Non volatile configuration storage in on-chip flash
 *         (decompiled from 0x8620-0x86DB and 0x8A85-0x8D67).
 *
 * The 128-byte configuration image (g_cfg, RAM 0x0120..0x019F) is stored
 * in one of two flash pages (bank A = 0x8000, bank B = 0x8200, 512 bytes
 * each).  Layout of an image:
 *   [0x00]      write counter, low byte  (counts DOWN from 0x1000)
 *   [0x7F]      write counter, high byte
 *   [0x5E/0x5F] check word, chosen so that the XOR of all 64 big-endian
 *               words of the image equals 0xCAFE
 *   others      application parameters (see app.h, struct Config)
 * At power-up the valid bank with the lowest counter (= newest) is used.
 * The remaining 384 bytes of the page are filled with 0x83 (SWI opcode).
 *
 * Erase/program must run from RAM (the flash array is not readable while
 * it is being programmed).  The original firmware pushes the routine
 * onto the stack and jumps to it; here the identical machine code is
 * copied into a RAM buffer and called (see Flash_RunInRam).
 */
#include "app.h"

/* ---- variables used by the RAM routines: they are addressed with direct
 *      (zero page) addressing by the machine code, so they MUST stay at
 *      these absolute addresses. ---------------------------------------- */
byte * volatile g_flashSrc   AT(0x00A0);   /* [0xA0] source pointer (RAM image)        */
byte * volatile g_flashDst   AT(0x00A2);   /* [0xA2] running flash destination pointer */
volatile byte   g_flashCount AT(0x00A4);   /* [0xA4] number of bytes to program        */
byte * volatile g_flashAddr  AT(0x00A8);   /* [0xA8] start address of the operation    */
volatile byte   g_flashFill  AT(0x00AA);   /* [0xAA] 1 = program filler 0x83 instead of data */

/* ---- module variables -------------------------------------------------- */
Config  g_cfg;                    /* [0x0120] RAM copy of the configuration image          */
byte    g_nvmBank;                /* [0x01AC] 1 = bank A valid, 2 = bank B valid, 3 = none */
word    g_nvmCounterB;            /* [0x01AD] write counter of bank B (0x8200)              */
word    g_nvmCounterA;            /* [0x01AF] write counter of bank A (0x8000)              */
byte   *g_nvmPage;                /* [0x01B1] page used by the next operation               */
byte    g_nvmState;               /* [0x01B3] save state machine (0 = idle)                 */
byte    g_diagState;              /* [0x02A2] diagnostics state (shared; also set by Nvm_Init) */

#define NVM_BANK_A   ((byte *)0x8000)
#define NVM_BANK_B   ((byte *)0x8200)
#define NVM_MAGIC    0xCAFEu

/* ======================================================================
 * Machine code executed from RAM.
 *
 * Burst program (original 0x8644-0x8683, the final "LDHX $A6 / TXS" that
 * restored the stack pointer was removed because the routine is CALLED
 * here instead of being jumped to on the stack):
 *
 *   L0: LDA  FSTAT        ; wait until the command buffer is empty
 *       AND  #$80
 *       BEQ  L0
 *       LDA  #$55         ; COP service, first half
 *       STA  SRS
 *       LDA  $AA          ; filler mode?
 *       CMP  #1
 *       BEQ  L1
 *       LDHX $A0          ; data = *src++
 *       LDA  ,X
 *       AIX  #1
 *       STHX $A0
 *       BRA  L2
 *   L1: LDA  #$83         ; data = 0x83
 *   L2: LDHX $A2          ; *dst++ = data
 *       STA  ,X
 *       AIX  #1
 *       STHX $A2
 *       LDA  #$25         ; burst program command
 *       STA  FCMD
 *       LDA  #$80         ; launch
 *       STA  FSTAT
 *       DBNZ $A4,L0       ; next byte
 *   L3: LDA  FSTAT        ; wait for FCCF
 *       LSLA
 *       BPL  L3
 *       LDA  #$AA         ; COP service, second half
 *       STA  SRS
 *       RTS
 * ====================================================================== */
static const byte s_burstProgCode[] = {
    0xC6,0x18,0x25, 0xA4,0x80, 0x27,0xF9, 0xA6,0x55, 0xC7,0x18,0x00,
    0xB6,0xAA, 0xA1,0x01, 0x27,0x09, 0x55,0xA0, 0xF6, 0xAF,0x01, 0x35,0xA0,
    0x20,0x02, 0xA6,0x83, 0x55,0xA2, 0xF7, 0xAF,0x01, 0x35,0xA2,
    0xA6,0x25, 0xC7,0x18,0x26, 0xA6,0x80, 0xC7,0x18,0x25, 0x3B,0xA4,0xCF,
    0xC6,0x18,0x25, 0x48, 0x2A,0xFA,
    0xA6,0xAA, 0xC7,0x18,0x00, 0x81
};

/*
 * Page erase (original 0x86B8-0x86DB):
 *       LDA  #$AA         ; COP service, second half
 *       STA  SRS
 *       LDHX $A2          ; dummy write to the page
 *       STA  ,X
 *       LDA  #$40         ; page erase command
 *       STA  FCMD
 *       LDA  #$80         ; launch
 *       STA  FSTAT
 *       NOP
 *       NOP
 *       NOP
 *   L0: LDA  #$55         ; keep the COP alive while waiting
 *       STA  SRS
 *       LDA  FSTAT        ; wait for FCCF
 *       LSLA
 *       BPL  L0
 *       RTS
 */
static const byte s_pageEraseCode[] = {
    0xA6,0xAA, 0xC7,0x18,0x00, 0x55,0xA2, 0xF7, 0xA6,0x40, 0xC7,0x18,0x26,
    0xA6,0x80, 0xC7,0x18,0x25, 0x9D, 0x9D, 0x9D,
    0xA6,0x55, 0xC7,0x18,0x00, 0xC6,0x18,0x25, 0x48, 0x2A,0xF5,
    0x81
};

static byte s_ramCode[64];        /* RAM buffer the routines are executed from */

typedef void (*RamFunc)(void);

/* Copies a machine code routine to RAM and executes it there. */
static void Flash_RunInRam(const byte *code, byte len)
{
    byte i;
    for (i = 0; i < len; i++) {
        s_ramCode[i] = code[i];
    }
    ((RamFunc)(void *)s_ramCode)();
}

/* ======================================================================
 * Flash_BurstProgram  [0x8620]
 * Programs g_flashCount bytes starting at g_flashAddr, either from
 * g_flashSrc (g_flashFill == 0) or with the filler byte 0x83.
 * ====================================================================== */
static void Flash_BurstProgram(void)
{
    SRS = 0xAA;
    g_flashDst = g_flashAddr;
    FSTAT = FSTAT_FPVIOL | FSTAT_FACCERR;          /* clear old errors */
    Flash_RunInRam(s_burstProgCode, sizeof(s_burstProgCode));
}

/* ======================================================================
 * Flash_ErasePage  [0x8684]
 * Erases the 512-byte page at g_flashAddr.  Waits for the FLL to be
 * locked and sets the flash clock divider (FCDIV = 0x4C, bus/(8*13)).
 * ====================================================================== */
static void Flash_ErasePage(void)
{
    while ((ICGS1 & ICGS1_LOCK) == 0) { }
    FSTAT |= FSTAT_FACCERR;
    FCDIV = 0x4C;
    SRS = 0x55;
    g_flashDst = g_flashAddr;
    FSTAT = FSTAT_FPVIOL | FSTAT_FACCERR;
    Flash_RunInRam(s_pageEraseCode, sizeof(s_pageEraseCode));
}

/* ======================================================================
 * Nvm_Checksum  [0x8D2A]
 * XOR of 'count' big-endian 16-bit words starting at 'p'.
 * ====================================================================== */
word Nvm_Checksum(const word *p, word count)
{
    word sum = 0;
    word i;
    for (i = 0; i < count; i++) {
        sum ^= *p++;
    }
    return sum;
}

/* ======================================================================
 * Nvm_Init  [0x8A85]
 * Selects the newest valid flash bank and loads it into g_cfg.  If no
 * bank is valid, default values are flagged (g_cfgDefaults) and bank A
 * is used.
 * ====================================================================== */
void Nvm_Init(void)
{
    word chkA, chkB;

    g_nvmCounterA = ((word)NVM_BANK_A[0x7F] << 8) + NVM_BANK_A[0];
    g_nvmCounterB = ((word)NVM_BANK_B[0x7F] << 8) + NVM_BANK_B[0];
    chkA = Nvm_Checksum((const word *)NVM_BANK_A, 0x40);
    chkB = Nvm_Checksum((const word *)NVM_BANK_B, 0x40);

    if ((g_nvmCounterA < g_nvmCounterB) && (g_nvmCounterA < 0x1001) && (chkA == NVM_MAGIC)) {
        g_nvmBank = 1;
        g_nvmPage = NVM_BANK_A;
    } else if ((g_nvmCounterB < g_nvmCounterA) && (g_nvmCounterB < 0x1001) && (chkB == NVM_MAGIC)) {
        g_nvmBank = 2;
        g_nvmPage = NVM_BANK_B;
    } else {
        g_nvmBank     = 3;
        g_cfgDefaults = 1;                 /* [0x029D] no valid configuration */
        g_nvmPage     = NVM_BANK_A;
        g_diagState   = 0x0E;              /* [0x02A2] */
    }
    g_nvmState = 0;
    Nvm_Load();                            /* [0x8CBC] */
    g_flashFill = 0;
    g_flashSrc  = (byte *)&g_cfg;
}

/* ======================================================================
 * Nvm_RequestSave  [0x8B39]
 * Starts a save cycle of g_cfg: decrements the write counter, stores it
 * in the image, recalculates the check word and selects the OTHER bank
 * as destination.  If saving is not possible (state machine busy, no
 * save request pending, counter exhausted) the "save finished" event is
 * raised at once.
 * ====================================================================== */
void Nvm_RequestSave(void)
{
    word chk;

    if ((g_nvmSaveRequest != 1) || (g_nvmState != 0)) {   /* [0x02B9] */
        Nvm_SetEvent(1);
        return;
    }
    g_nvmState = 1;

    if ((g_nvmBank == 1) && (g_nvmCounterA >= 0x86)) {
        g_nvmCounterA--;
        g_cfg.raw[0x7F] = (byte)(g_nvmCounterA >> 8);
        g_cfg.raw[0x00] = (byte)g_nvmCounterA;
        g_cfg.raw[0x5E] = 0xCA;
        g_cfg.raw[0x5F] = 0xFE;
        chk = Nvm_Checksum((const word *)&g_cfg, 0x40);
        g_cfg.raw[0x5E] = (byte)(chk >> 8);
        g_cfg.raw[0x5F] = (byte)chk;
        g_nvmPage = NVM_BANK_B;
    } else if ((g_nvmBank == 2) && (g_nvmCounterB >= 0x86)) {
        g_nvmCounterB--;
        g_cfg.raw[0x7F] = (byte)(g_nvmCounterB >> 8);
        g_cfg.raw[0x00] = (byte)g_nvmCounterB;
        g_cfg.raw[0x5E] = 0xCA;
        g_cfg.raw[0x5F] = 0xFE;
        chk = Nvm_Checksum((const word *)&g_cfg, 0x40);
        g_cfg.raw[0x5E] = (byte)(chk >> 8);
        g_cfg.raw[0x5F] = (byte)chk;
        g_nvmPage = NVM_BANK_A;
    } else {
        g_nvmState       = 0;
        g_nvmSaveRequest = 0;
        Nvm_SetEvent(1);
    }
}

/* ======================================================================
 * Nvm_Process  [0x8BEA]
 * Save state machine, executed from NvmTask_Run (interrupts disabled).
 *   1: prepare (destination address)
 *   2: erase the destination page            -> returns 21 (ticks used)
 *   3: program 128 data bytes + 0x83 filler   -> returns 11
 *   4: verify; on mismatch restart at 1
 *   5: done -> raise "save finished" event
 * Returns the approximate number of ticks the operation blocked the CPU.
 * ====================================================================== */
byte Nvm_Process(void)
{
    byte ticks = 0;

    if (g_nvmState == 0) {
        return 0;
    }
    switch (g_nvmState) {
    case 1:
        g_nvmSaveRequest = 0;
        g_flashAddr = g_nvmPage;
        g_nvmState = 2;
        break;

    case 2:
        EnterCritical();
        Flash_ErasePage();
        ExitCritical();
        ticks = 0x15;
        g_nvmState = 3;
        break;

    case 3:
        g_flashSrc   = (byte *)&g_cfg;
        g_flashCount = 0x80;                       /* 128 data bytes      */
        EnterCritical();
        g_flashFill = 0;
        Flash_BurstProgram();
        g_flashFill = 1;                           /* rest of the page = 0x83 */
        g_flashAddr  = g_nvmPage + 0x80;
        g_flashCount = 0x7F;
        Flash_BurstProgram();
        g_flashFill = 1;
        g_flashAddr  = g_nvmPage + 0x100;
        g_flashCount = 0xFF;
        Flash_BurstProgram();
        ExitCritical();
        ticks = 0x0B;
        g_nvmState = 4;
        break;

    case 4:
        if (Nvm_Verify()) {
            g_nvmState = 5;
        } else {
            g_nvmState = 1;                        /* retry */
        }
        break;

    case 5:
        Nvm_SetEvent(1);
        g_nvmState = 0;
        break;

    default:
        g_nvmState = 0;
        break;
    }
    return ticks;
}

/* ======================================================================
 * Nvm_Load  [0x8CBC]
 * Copies the selected flash page into g_cfg unless they are already
 * identical or a save is in progress.
 * ====================================================================== */
void Nvm_Load(void)
{
    byte i;
    byte *p;

    if (Nvm_Verify() == 0 && g_nvmSaveRequest == 0 && g_nvmState == 0) {
        p = g_nvmPage;
        if (p != 0) {
            for (i = 0; i < 0x80; i++) {
                g_cfg.raw[i] = p[i];
            }
        }
    }
}

/* ======================================================================
 * Nvm_Verify  [0x8CF3]
 * Returns 1 if g_cfg is identical to the selected flash page.
 * ====================================================================== */
byte Nvm_Verify(void)
{
    byte  i;
    byte  equal = 1;
    byte *p = g_nvmPage;

    if (p != 0) {
        for (i = 0; i < 0x80; i++) {
            if (p[i] != g_cfg.raw[i]) {
                equal = 0;
            }
        }
    }
    return equal;
}
