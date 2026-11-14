/*
 * diag.c - Diagnostics / output-stage test
 *          (decompiled from Diag_Init 0xB5A3, Diag_Task 0xB4D7,
 *           Diag_SlowTask 0xB5AA and Diag_sub_B620 0xB620).
 *
 * Diag_Task reconfigures the port pin functions for the diagnostic
 * (test) pin mapping; Diag_SlowTask performs a short actuator pulse on
 * TPM1 channel 2 when a diagnostic test has been requested (0x0270) and,
 * for the non-PWM variant with no controller error, leaves the test pin
 * idle afterwards.  Diag_sub_B620 is the common "stop the TPM1-CH2 test
 * output" helper.
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))

byte g_diagRequest AT(0x0270);   /* [0x0270] 1 = run the output test */

/* ======================================================================
 * Diag_StopTestOutput  [0xB620]
 * Disables the TPM1 channel-2 test output and reloads its compare value.
 * ====================================================================== */
static void Diag_StopTestOutput(void)
{
    R8(0x000A) &= (byte)~0x01;        /* PTFPE / pin control bit off */
    TPM1C2SC = 0x00;
    R8(0x000A) &= (byte)~0x01;
    TPM1C2VH = 0xC8;
    TPM1C2VL = 0x00;
}

/* ======================================================================
 * Diag_Init  [0xB5A3]
 * Puts the output test into the stopped state and clears the request.
 * ====================================================================== */
void Diag_Init(void)
{
    Diag_StopTestOutput();
    g_diagRequest = 0;
}

/* ======================================================================
 * Diag_Task  [0xB4D7]
 * Switches the port pin functions to the diagnostic mapping (the same
 * read-modify-write sequence on the PTxDD/PTxPE control page 0x0001..0x000D
 * as Ports_Init, but with the test-pin configuration).  Exact masks are in
 * reference/application.asm 0xB4D7-0xB518.
 * ====================================================================== */
void Diag_Task(void)
{
    R8(0x0001) |= 0x01;  R8(0x0001) &= 0xFD;
    R8(0x0003) &= 0xFB;
    R8(0x0005) &= 0xC1;  R8(0x0005) |= 0x01;
    R8(0x0007) &= 0xF0;
    R8(0x0009) &= 0xBF;  R8(0x0009) |= 0x8C;
    R8(0x000B) |= 0x11;  R8(0x000B) &= 0xDF;
    R8(0x000D) &= 0x90;
}

/* ======================================================================
 * Diag_SlowTask  [0xB5AA]
 * When a diagnostic output test is pending, pulse the TPM1-CH2 test
 * output for ~100 delay units then stop it; afterwards, for the non-PWM
 * output variant with no controller fault, disable the test pin.
 * ====================================================================== */
void Diag_SlowTask(void)
{
    if (g_diagRequest != 0) {
        Diag_StopTestOutput();
        R8(0x000A) |= 0x01;             /* enable the test pin */
        Delay_Loop(0x64);
        g_diagRequest = 0;
        /* sub LB5E4: finalise the pulse (see asm 0xB5E4) */
    }
    if (g_outputVariant == 0 && g_ctrlErrFlag == 0) {
        R8(0x000A) &= (byte)~0x01;      /* leave the test pin idle */
    }
}
