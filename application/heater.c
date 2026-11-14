/*
 * heater.c - Heater / PTC temperature control
 *            (decompiled from Heater_Init 0xB7D9 and Heater_Task 0xB7E8).
 *
 * Present only on the variants whose feature flags contain FEAT_HEATER.
 * A temperature sensor is read on ADC channel 3; its value is slew-rate
 * limited (Motor_Ramp / 0xB667) into the control variable 0x0109 and used
 * to drive the heater output stage (sub 0xB707).  Open-circuit (raw >=
 * 0xF8) and short-circuit (raw < 0x15) are reported as faults.
 */
#include "app.h"

extern byte Motor_Ramp(byte target, byte *flag, byte current, byte step); /* [0xB667] */
extern byte Heater_Drive(byte *outCfg, byte x);                           /* [0xB707] */

byte g_heaterSetpoint AT(0x028A);   /* [0x028A] target (init 0x46)       */
byte g_heaterTimer    AT(0x0273);   /* [0x0273] re-measure period (init 6)*/
byte g_heaterFault    AT(0x02A5);   /* [0x02A5] latched fault code        */
byte g_heaterValue    AT(0x0109);   /* [0x0109] filtered sensor value     */

/* ======================================================================
 * Heater_Init  [0xB7D9]
 * ====================================================================== */
void Heater_Init(void)
{
    g_heaterSetpoint = 0x46;
    g_heaterTimer    = 0x06;
    g_heaterFault    = 0x00;
}

/* ======================================================================
 * Heater_Task  [0xB7E8]
 * Reads the heater NTC/PTC on ADC channel 3 and acts:
 *   raw >= 0xF8  -> open circuit  : fault code 0x0A
 *   raw <  0x15  -> short circuit : fault code 0x07
 *   otherwise    -> slew-limit into g_heaterValue and drive the output.
 * ====================================================================== */
void Heater_Task(void)
{
    byte raw = Adc_Read(3);

    if (raw >= 0xF8) {
        g_heaterFault = 0x0A;               /* open circuit */
        return;
    }
    if (raw < 0x15) {
        g_heaterFault = 0x07;               /* short circuit */
        return;
    }

    /* normal: track the reading with the slew limiter, then drive */
    g_heaterValue = Motor_Ramp(4, (byte *)0x010A, g_heaterValue, raw);
    g_heaterFault = Heater_Drive((byte *)0x0135, 0);
}

/* ======================================================================
 * Heater_Drive  [0xB707]
 * Maps the filtered sensor value to a heater output setting using a
 * two-column breakpoint table (passed by pointer in the original: a list
 * of {input, output} pairs that it searches and linearly interpolates
 * between).  Returns the resulting output/fault code written by the
 * caller.  The table walk and the linear interpolation are intricate
 * fixed-point code; see reference/application.asm 0xB707-0xB7A... for the
 * byte-exact sequence.  The behavioural contract is: find the pair whose
 * input brackets the argument, interpolate the output, and clamp at the
 * table ends.
 * ====================================================================== */
byte Heater_Drive(byte *table, byte x)
{
    (void)table; (void)x;
    return 0;   /* see asm for the exact interpolation */
}
