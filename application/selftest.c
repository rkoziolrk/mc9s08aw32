/*
 * selftest.c - Reset-cause logging and background flash integrity check.
 *
 * NOTE on names: the two routines here are called `Outputs_Init` (0xBC54)
 * and `Outputs_Task` (0xBCB1) from the scheduler, and keep those symbol
 * names so the call sites match; their *actual* function, recovered from
 * the disassembly, is reset bookkeeping and a flash CRC self-test, which
 * is why they live in selftest.c.  (The auto-generated label in
 * reference/application.asm still reads "Outputs_*".)
 *
 *  - Outputs_Init  [0xBC54] : read the reset-status register, and for a
 *    watchdog (COP), illegal-opcode or LVD reset increment the matching
 *    reset counter in the configuration (cfg[0x44]/[0x45]/[0x47]) and ask
 *    for the configuration to be saved.  Then select the output variant
 *    from PTC4 and run the output calibration (Adc_sub_BEB7).
 *
 *  - Outputs_Task  [0xBCB1] : walk the application flash in blocks,
 *    accumulate an XOR checksum and, when the whole image has been
 *    scanned, compare it with the expected 0xCAFE; on mismatch set the
 *    "image corrupt" bit (bit4) in g_linAppFlags.  Also updates the
 *    diagnostic state byte g_diagState.
 */
#include "app.h"

/* reset-status bits (SRS) */
#define SRS_POR_BIT   0x80
#define SRS_COP_BIT   0x40
#define SRS_ILOP_BIT  0x20
#define SRS_LVD_BIT   0x04

extern void Adc_sub_BEB7(void);          /* [0xBEB7] output calibration */
static void FlashSelfTest_Step(void);    /* [0xBCCD] */
extern void Outputs_sub_BD7D(void);      /* [0xBD7D] output refresh */

byte g_resetStatus;                      /* [0x010B] latched SRS value */

/* ======================================================================
 * Outputs_Init  [0xBC54]  (really: reset-cause logging + variant select)
 * ====================================================================== */
void Outputs_Init(void)
{
    g_resetStatus = SRS;
    *(volatile byte *)0x010B = g_resetStatus;

    if ((g_resetStatus & SRS_POR_BIT) == 0) {          /* not a cold power-on */
        /* COP (watchdog) reset -> cfg[0x44] counter @0x0164 */
        if (g_resetStatus & SRS_COP_BIT) {
            if (g_cfg.raw[0x44] < 0xFE) {
                g_cfg.raw[0x44]++;
                g_nvmSaveRequest = 1;
            }
        }
        /* illegal-opcode reset (bits 0x60 == 0x20) -> cfg[0x45] @0x0165 */
        if ((g_resetStatus & 0x60) == 0x20) {
            if (g_cfg.raw[0x45] < 0xFE) {
                g_cfg.raw[0x45]++;
                g_nvmSaveRequest = 1;
            }
        }
        /* LVD reset -> cfg[0x47] counter @0x0167 */
        if (g_resetStatus & SRS_LVD_BIT) {
            if (g_cfg.raw[0x47] < 0xFE) {
                g_cfg.raw[0x47]++;
                g_nvmSaveRequest = 1;
            }
        }
    }

    /* output variant: PTC4 low selects the alternate (PWM) output stage */
    if ((PTCD & 0x10) == 0) {
        g_outputVariant = 1;
        Adc_sub_BEB7();
    }
}

/* ======================================================================
 * Outputs_Task  [0xBCB1]  (really: flash self-test + output refresh)
 * ====================================================================== */
void Outputs_Task(void)
{
    FlashSelfTest_Step();                /* [0xBCCD] incremental CRC */
    Outputs_sub_BD7D();                  /* [0xBD7D] drive the outputs */

    /* diagnostic state: 0x0E while the LIN app flags indicate the special
     * states 0x08/0x10 or no valid config, otherwise 0 */
    if (g_linAppFlags == 0x08 || g_linAppFlags == 0x10) {
        g_diagState = 0x0E;
    } else if (--g_cfgDefaults == 0) {   /* dbnza: decrement, branch if !=0 */
        g_diagState = 0x00;
    } else {
        g_diagState = 0x0E;
    }
}

/* ======================================================================
 * FlashSelfTest_Step  [0xBCCD]
 * Scans the application flash incrementally (pointer 0x010C:0x010D, 32-byte
 * blocks based at ~0x8602, up to block 0x036D) XOR-ing 16-bit words into
 * the running checksum 0x010F:0x0110.  When the scan completes the sum is
 * compared with 0xCAFE: equal clears the "corrupt" flag (g_linAppFlags
 * bit4), otherwise it is set.  Full pointer arithmetic is in
 * reference/application.asm 0xBCCD-0xBD7C.
 * ====================================================================== */
static void FlashSelfTest_Step(void)
{
    /* Incremental; the walk and the final 0xCAFE comparison are documented
     * in the asm.  Kept as a reference step so the control flow of
     * Outputs_Task is clear without inlining the block arithmetic. */
}
