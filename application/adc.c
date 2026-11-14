/*
 * DEVICE NOTE: 'variant detection' here is the STEERING-WHEEL CODING (which
 * button set is fitted); Adc_Read(ch 2) reads the BUTTON RESISTOR LADDER.
 * adc.c - ADC driver and hardware-variant detection
 *         (decompiled from 0xA103, 0xBEC2-0xBFA6 and 0xBFA7-0xC047).
 *
 * The board carries a "coding" input: a resistor divider on ADC channel
 * 0x0B whose voltage identifies which hardware variant the firmware is
 * running on.  Adc_DetectVariant() reads that channel once at start-up
 * and maps the 8-bit result into:
 *      g_variantCode  - the variant number (1,2,3,4,7,8,9,10,11,14)
 *      g_variantSub   - a sub-code (always 1 for the valid bands)
 *      g_featureFlags - the bitmask of enabled features (FEAT_*)
 * A reading that falls in none of the valid bands sets g_testMode = 1,
 * which disables the motor/heater/fault tasks (see main.c).
 *
 * Variant_ReadStraps() additionally samples five coding/strap inputs and
 * packs them into g_codingByte (used by the LIN identification signals).
 */
#include "app.h"

/* variant detection results */
byte g_codingByte;      /* [0x0298] */
byte g_featureFlags;    /* [0x0299] */
byte g_variantCode;     /* [0x02EC] */
byte g_variantSub;      /* [0x02EB] */
byte g_testMode;        /* [0x02EA] */

/* ======================================================================
 * Adc_Read  [0xA103]
 * Starts a single software-triggered conversion on 'channel' (masked to
 * 5 bits), waits for completion (COCO) and returns the low 8 bits of the
 * result.  channel 0x1F is the ADC "module disable" code: it is written
 * to ADC1SC1 to power the ADC down and 0xFF is returned.
 * ====================================================================== */
byte Adc_Read(byte channel)
{
    channel &= 0x1F;
    if (channel == 0x1F) {
        ADC1SC1 = 0x1F;                  /* power down the ADC */
        return 0xFF;
    }
    ADC1SC1 = channel;                   /* start conversion, SW trigger, no int */
    Delay_Loop(2);                       /* short settling delay [via Delay_Loop] */
    while ((ADC1SC1 & ADC_SC1_COCO) == 0) {
        /* wait for conversion complete */
    }
    return ADC1RL;                       /* 8-bit result (low byte) */
}

/* ======================================================================
 * Adc_Init  [0xBEC2]
 * Detects the hardware variant, then runs the low-level output/ADC setup.
 * ====================================================================== */
void Adc_Init(void)
{
    Adc_DetectVariant();                 /* [0xBEC7] */
    Variant_ReadStraps();                /* [0xBFA7] (reached via jmp 0xBFA7) */
}

/* ======================================================================
 * Adc_DetectVariant  [0xBEC7]
 * Reads the coding channel (0x0B) and classifies it.  The [lo,hi) bands
 * and their results are exactly those coded in the firmware.
 * ====================================================================== */
void Adc_DetectVariant(void)
{
    byte v = Adc_Read(0x0B);             /* read the coding divider */

    g_testMode = 0;

    if (v >= 0x11 && v < 0x19) {         /* band 1 */
        g_variantCode  = 1;
        g_variantSub   = 1;
        g_featureFlags = 0x00;
    } else if (v >= 0x1D && v < 0x26) {  /* band 2 */
        g_variantCode  = 2;
        g_variantSub   = 1;
        g_featureFlags = 0x02;           /* heater */
    } else if (v >= 0x2A && v < 0x34) {  /* band 3 */
        g_variantCode  = 3;
        g_variantSub   = 1;
        g_featureFlags = 0x01;
    } else if (v >= 0x39 && v < 0x44) {  /* band 4 */
        g_variantCode  = 4;
        g_variantSub   = 1;
        g_featureFlags = 0x03;           /* heater + bit0 */
    } else if (v >= 0x6A && v < 0x77) {  /* band 5 */
        g_variantCode  = 7;
        g_variantSub   = 1;
        g_featureFlags = 0x08;
    } else if (v >= 0x7C && v < 0x8A) {  /* band 6 */
        g_variantCode  = 8;
        g_variantSub   = 1;
        g_featureFlags = 0x09;
    } else if (v >= 0x8E && v < 0x9E) {  /* band 7 */
        g_variantCode  = 9;
        g_variantSub   = 1;
        g_featureFlags = 0x0F;           /* all four feature bits */
    } else if (v >= 0xA3 && v < 0xB2) {  /* band 8 */
        g_variantCode  = 0x0A;
        g_variantSub   = 1;
        g_featureFlags = 0x0C;           /* motor + bit3 */
    } else if (v >= 0xB7 && v < 0xC9) {  /* band 9 */
        g_variantCode  = 0x0B;
        g_variantSub   = 1;
        g_featureFlags = 0x0B;           /* bit0 + heater + bit3 */
    } else {                             /* out of range -> test mode */
        g_variantCode  = 0x0E;
        g_testMode     = 1;
    }
}

/* ----------------------------------------------------------------------
 * Strap coding table (flash 0xC245..0xC24F), indexed by strap number.
 *   s_strapPort[i]  - pointer to the input register of strap i
 *   s_strapMask[i]  - the bit mask within that register
 * The packed table in flash is:  {portPtrHi,portPtrLo,mask} per entry,
 * read here as two parallel arrays.
 * -------------------------------------------------------------------- */
static volatile byte * const s_strapPort[5] = {
    &PTAD, &PTBD, &PTCD, &PTDD, &PTED     /* (addresses taken from 0xC245 table) */
};
static const byte s_strapMask[5] = { 0x08, 0x10, 0x20, 0x40, 0x40 };

/* ======================================================================
 * Variant_ReadStraps  [0xBFA7]
 * Samples the five coding/strap inputs and packs them MSB-first into
 * g_codingByte, then puts the coding pins back to their quiescent state
 * (pull-ups off, PTG low).  The exact register/mask pairs come from the
 * table at flash 0xC245; see reference/application.asm for the raw form.
 * ====================================================================== */
void Variant_ReadStraps(void)
{
    byte i;
    byte code = 0;

    for (i = 0; i < 5; i++) {
        byte bit = (*s_strapPort[i] & s_strapMask[i]) ? 0 : 1;
        code = (byte)((code << 1) | bit);
    }
    /* firmware remaps the raw code: 1 stays 1, anything else has 0x16
     * subtracted (see 0xC015-0xC021). */
    if (code == 0x01) {
        g_codingByte = 0x01;
    } else {
        g_codingByte = (byte)(code - 0x16);
    }

    /* restore the coding pins / disable their pull-ups (0xC022-0xC044) */
    PTBDD   |= 0x01;
    PTED    |= 0x81;
    PTGD     = 0x00;
    PTCPE    = 0x00;
    PTEPE    = 0x00;
    PTEDD   |= 0xFD;
    PTGPE    = 0x00;
}
