/*
 * DEVICE NOTE: not a cabin heater -- an auxiliary analogue input (ch 3)
 * with open/short detection on this steering-wheel module. See DEVICE.md.
 * heating.c - Heater / PTC temperature control
 *            (decompiled from Heating_Init 0xB7D9 and Heating_Task 0xB7E8).
 *
 * Present only on the variants whose feature flags contain FEAT_HEATER.
 * A temperature sensor is read on ADC channel 3; its value is slew-rate
 * limited (Ramp_Limit / 0xB667) into the control variable 0x0109 and used
 * to drive the heater output stage (sub 0xB707).  Open-circuit (raw >=
 * 0xF8) and short-circuit (raw < 0x15) are reported as faults.
 */
#include "app.h"

extern byte Ramp_Limit(byte target, byte *flag, byte current, byte step); /* [0xB667] */
extern byte Heating_Curve(byte *outCfg, byte x);                           /* [0xB707] */

byte g_heaterSetpoint AT(0x028A);   /* [0x028A] target (init 0x46)       */
byte g_heaterTimer    AT(0x0273);   /* [0x0273] re-measure period (init 6)*/
byte g_heaterFault    AT(0x02A5);   /* [0x02A5] latched fault code        */
byte g_heaterValue    AT(0x0109);   /* [0x0109] filtered sensor value     */

/* ======================================================================
 * Heating_Init  [0xB7D9]
 * ====================================================================== */
void Heating_Init(void)
{
    g_heaterSetpoint = 0x46;
    g_heaterTimer    = 0x06;
    g_heaterFault    = 0x00;
}

/* ======================================================================
 * Heating_Task  [0xB7E8]
 * Reads the heater NTC/PTC on ADC channel 3 and acts:
 *   raw >= 0xF8  -> open circuit  : fault code 0x0A
 *   raw <  0x15  -> short circuit : fault code 0x07
 *   otherwise    -> slew-limit into g_heaterValue and drive the output.
 * ====================================================================== */
void Heating_Task(void)
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
    g_heaterValue = Ramp_Limit(4, (byte *)0x010A, g_heaterValue, raw);
    g_heaterFault = Heating_Curve((byte *)0x0135, 0);
}

/* ======================================================================
 * Heating_Curve  [0xB707]
 * Piecewise-linear lookup over a breakpoint table of {x,y} byte pairs
 * (the table pointer is the argument; entries are 2 bytes and are walked
 * with +2).  Finds the segment [p-1, p] whose x values bracket the input,
 * then interpolates:
 *     y = y_prev + (x - x_prev) * (y_cur - y_prev) / (x_cur - x_prev)
 * using the 16-bit mul16/div16 helpers.  Clamps to the first entry's y
 * when the input is below the first breakpoint (the 0xB7AB tail), and to
 * the last segment at the top end.  Reconstructed from
 * reference/application.asm 0xB707-0xB7B6.
 *
 * Table format: table[0]=x0, table[1]=y0, table[2]=x1, table[3]=y1, ...
 * The caller's end marker is reached when x_cur does not advance past the
 * input (0xB730 test), i.e. the final pair.
 * ====================================================================== */
byte Heating_Curve(byte *table, byte x)
{
    byte x_prev, y_prev, x_cur, y_cur;
    int  dy, dx;

    /* below the first breakpoint -> clamp to its y (asm LB7AB) */
    if (x < table[0]) {
        return table[1];
    }

    /* walk pairs until x_cur >= x (or the table ends) */
    for (;;) {
        x_prev = table[0];
        y_prev = table[1];
        if (table[0] >= x) {
            break;                         /* exact / first bracket */
        }
        x_cur = table[2];
        y_cur = table[3];
        if (x_cur >= x) {
            /* input falls in [x_prev, x_cur] -> interpolate */
            dy = (int)y_cur - (int)y_prev;
            dx = (int)x_cur - (int)x_prev;
            if (dx == 0) {
                return y_prev;
            }
            return (byte)(y_prev + (int)mul16((word)(x - x_prev), (word)dy) / dx);
        }
        table += 2;                        /* next segment */
    }
    (void)x_prev;
    return y_prev;                         /* at/after a breakpoint */
}
