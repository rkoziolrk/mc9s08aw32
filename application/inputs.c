/*
 * inputs.c - Initialisation of the input / signal-state RAM
 *            (decompiled from Inputs_Init, 0xB84D).
 *
 * Clears and seeds the large block of application state variables that
 * hold the debounced inputs, the per-channel measurement results and the
 * LIN-published signal values.  Called once from App_InitAll().  The exact
 * addresses are preserved because other modules reach the same variables.
 */
#include "app.h"

/* ======================================================================
 * Inputs_Init  [0xB84D]
 * Zero/seed the input and signal state.  Notable seeds:
 *   0x02D6 = 0x0F, 0x02D8 = 0x0F      (two "no-fault" nibble markers)
 *   0x02C5[i] = 0x0F (i=0..5)         (per-channel input defaults)
 *   0x02B3 = 1, 0x02B0 (g_testRequest) = 1
 *   0x029A = 2
 * Everything else in 0x0278..0x02DC and 0x029B..0x02BF is cleared.
 * ====================================================================== */
void Inputs_Init(void)
{
    byte i;

    *(volatile byte *)0x02D6 = 0x0F;
    *(volatile byte *)0x02D7 = 0x00;
    *(volatile byte *)0x02D8 = 0x0F;
    *(volatile byte *)0x02D9 = 0x00;
    *(volatile byte *)0x02D3 = 0x00;
    *(volatile byte *)0x02D1 = 0x00;

    /* six input channels: value byte 0x02C5[i] default 0x0F, aux 0x02C6[i]=0,
     * and a per-channel flag at 0x02BF[i]=0 */
    for (i = 0; i < 6; i++) {
        *(volatile byte *)(0x02C5 + i * 2) = 0x0F;
        *(volatile byte *)(0x02C6 + i * 2) = 0x00;
        *(volatile byte *)(0x02BF + i)     = 0x00;
    }

    *(volatile byte *)0x02BE = 0x00;
    *(volatile byte *)0x02BD = 0x00;
    *(volatile byte *)0x02BC = 0x00;
    g_nvmSaveRequest = 0;
    *(volatile byte *)0x02B7 = 0x00;
    *(volatile byte *)0x02B8 = 0x00;
    g_supplyVoltage = 0x00;
    *(volatile byte *)0x02B4 = 0x00;
    *(volatile byte *)0x02B5 = 0x00;
    *(volatile byte *)0x02B3 = 0x01;
    *(volatile byte *)0x02B2 = 0x00;
    *(volatile byte *)0x02B1 = 0x00;
    g_testRequest   = 0x01;
    g_linAppFlags   = 0x00;
    g_cfgDefaults   = 0x00;

    /* status signal array 0x029F[0..14] cleared */
    for (i = 0; i < 0x0F; i++) {
        *(volatile byte *)(0x029F + i) = 0x00;
    }
    *(volatile byte *)0x029C = 0x00;
    *(volatile byte *)0x029B = 0x00;
    *(volatile byte *)0x029A = 0x02;

    /* signal-build work area 0x0278.. cleared (remainder of the routine) */
    for (i = 0; i < 0x0F; i++) {
        *(volatile byte *)(0x0278 + i) = 0x00;
    }
}
