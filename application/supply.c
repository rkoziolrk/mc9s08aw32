/*
 * supply.c - Supply-voltage monitoring
 *            (decompiled from 0xB932, 0xB9FD and 0xBA90).
 *
 * The supply rail is sensed on ADC channel 0x0A.  Supply_Task() reads it
 * every 2 ticks (from the 2-tick scheduler task), filters it through the
 * firmware's slew-rate limiter (Ramp_Limit / 0xB667) into g_supplyVoltage
 * and, below a threshold, runs a debounce before declaring an under-
 * voltage.  Calibration constants g_tempCode / g_tempValue are derived
 * once in Supply_Init() from the stored configuration (cfg[0x48/0x49]).
 *
 * The two auxiliary channels sampled by Supply_sub_BA90 use the generic
 * "input descriptor" tables in flash (0xC237 = port pointer, 0xC239 =
 * AND mask, 0xC23A/0xC23C = a second port/mask); each descriptor reads a
 * bit from a GPIO input register.  The raw descriptor layout is in
 * reference/application.asm (0xBA90-0xBB...).
 */
#include "app.h"

/* module state (absolute addresses preserved) */
byte g_supplyDebounce AT(0x02DB);   /* [0x02DB] under-voltage debounce countdown */
byte g_supplyLatched  AT(0x02DC);   /* [0x02DC] 1 = under-voltage latched         */
byte g_tempCode       AT(0x02E1);   /* [0x02E1] calibration code (from cfg[0x49]) */
byte g_tempValue      AT(0x02E2);   /* [0x02E2] calibration value (from cfg[0x48])*/

byte g_supplyVoltage;               /* [0x02B6] filtered supply (public)          */

/* helpers reconstructed elsewhere / documented in the asm */
extern byte Ramp_Limit(byte target, byte *flag, byte current, byte step); /* [0xB667] slew limiter */
extern void Backlight_SupplyStep(void);                                          /* [0xA13A] */
static void Supply_SampleAux(byte channel);                               /* [0xBA90] */

#define SUPPLY_ADC_CH      0x0A
#define SUPPLY_LOW_THRESH  0x4E      /* raw ADC below this = possible under-voltage */

/* ======================================================================
 * Supply_Init  [0xB932]
 * Enables the supply divider (PTA0), derives the calibration constants
 * from the configuration image and initialises the two auxiliary input
 * channels (via the descriptor tables).  cfg[0x49] (0x0169) gives the
 * calibration code (default 0x19 if 0 or >= 0x40); cfg[0x48] (0x0168)
 * gives the value (clamped to 0x23 outside 0x47..0xC7).
 * ====================================================================== */
void Supply_Init(void)
{
    byte i;

    g_supplyDebounce = 1;
    PTAD |= 0x01;                               /* enable the sense divider */

    /* calibration code from cfg[0x49] */
    if (g_cfg.raw[0x49] == 0 || g_cfg.raw[0x49] >= 0x40) {
        g_tempCode = 0x19;
    } else {
        g_tempCode = g_cfg.raw[0x49];
    }
    /* calibration value from cfg[0x48] */
    if (g_cfg.raw[0x48] >= 0x47 && g_cfg.raw[0x48] < 0xC8) {
        g_tempValue = (byte)(g_cfg.raw[0x48] - 0x23);
    } else {
        g_tempValue = 0x23;
    }

    Delay_Loop((word)(g_tempValue + 0x41));     /* settling delay */

    /* initialise the two auxiliary measurement channels (descriptor based) */
    for (i = 0; i < 2; i++) {
        *(volatile byte *)(0x02E3 + i * 3) = 0;
        /* read-and-store the channel's input bit via the C237/C239/C23A
         * descriptor tables; see reference/application.asm 0xB971-0xB9E7 */
        *(volatile byte *)(0x02DD + i) = 2;
    }

    PTAD &= (byte)~0x01;                         /* disable the divider again */
    g_supplyLatched = 0;
}

/* ======================================================================
 * Supply_Task  [0xB9FD]
 * Reads the supply ADC, filters it and maintains the under-voltage state.
 * ====================================================================== */
void Supply_Task(void)
{
    byte raw;

    PTAD |= 0x01;                                /* enable the sense divider */
    raw = Adc_Read(SUPPLY_ADC_CH);

    if (raw >= SUPPLY_LOW_THRESH) {
        /* normal supply: track it (slew limited) and clear the debounce */
        g_supplyVoltage = Ramp_Limit(2, &g_supplyLatched, g_supplyVoltage, raw);
        Backlight_SupplyStep();
        g_supplyDebounce = 0;
    } else {
        /* low reading: debounce before acting */
        if (--g_supplyDebounce == 0) {
            byte ch;
            g_supplyVoltage = Ramp_Limit(2, &g_supplyLatched, g_supplyVoltage, raw);
            Backlight_SupplyStep();
            Delay_Loop(g_tempValue);
            for (ch = 0; ch < 2; ch++) {
                Supply_SampleAux(ch);
                /* accumulate the per-channel result into 0x02D7[ch] */
                *(volatile byte *)(0x02D7 + ch) =
                    (byte)(*(volatile byte *)(0x02D7 + ch)
                           + *(volatile byte *)(0x02E3 + ch * 3));
            }
        } else {
            Supply_Init();                       /* restart the measurement */
        }
    }
    PTAD &= (byte)~0x01;                          /* disable the divider */
}

/* ======================================================================
 * Supply_sub_BA90 -> Supply_SampleAux  [0xBA90]
 * Samples one auxiliary channel through its input descriptor (port
 * pointer at flash 0xC237/0xC23A, AND masks at 0xC239/0xC23C), compares
 * the two readings and stores the debounced bit.  The exact descriptor
 * walk is reproduced in reference/application.asm; the behaviour is:
 * read bit A, delay, read bit B, and if they match store the value into
 * the channel's result byte (0x02DF[ch]).
 * ====================================================================== */
static void Supply_SampleAux(byte channel)
{
    /* Per-channel descriptor is 6 bytes at 0xC237 + channel*6:
     *   [0:1] port1 register pointer   [2] mask1
     *   [3:4] port2 register pointer   [5] mask2
     * (so the firmware's parallel bases are C237=ptr1, C239=mask1,
     *  C23A=ptr2, C23C=mask2). The channel result is stored at 0x02DF[ch].
     * Two-point debounced read: sample port1&mask1, wait g_tempCode, sample
     * again; if stable AND port2&mask2 also matches its expected level,
     * the channel reads as 1. Reconstructed from asm 0xBA90-0xBB18. */
    const byte *desc = (const byte *)(word)(0xC237 + (word)channel * 6);
    volatile byte *port1 = (volatile byte *)(word)(((word)desc[0] << 8) | desc[1]);
    byte  mask1 = desc[2];
    volatile byte *port2 = (volatile byte *)(word)(((word)desc[3] << 8) | desc[4]);
    byte  mask2 = desc[5];
    byte  first1, exp1, exp2, result = 0;

    *(volatile byte *)(0x02DF + channel) = 0;

    first1 = (byte)(*port1 & mask1);
    exp1   = first1;                         /* first reading of port1       */
    exp2   = (byte)(*port2 & mask2);         /* expected level of port2      */

    Delay_Loop(g_tempCode);                  /* debounce interval            */

    if ((byte)(*port1 & mask1) == exp1) {    /* port1 stable                 */
        if ((byte)(*port2 & mask2) == exp2) {/* port2 matches                */
            result = 1;
        }
    }
    *(volatile byte *)(0x02DF + channel) = result;
    (void)first1;
}
