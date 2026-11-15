/*
 * adc.c - ADC driver + start-up option/presence coding
 *         (decompiled from 0xA103, 0xBEC2-0xBFA6 and 0xBFA7-0xC047).
 *
 * DEVICE: Audi A4 B8 multifunction steering-wheel button panel.
 *   Adc_Read channels actually sampled by the firmware:
 *     ch 0x02  button RESISTOR LADDER (and output-stage feedback)
 *     ch 0x03  heating NTC
 *     ch 0x0A  supply / output feedback
 *     ch 0x0B  start-up coding (read exactly once, in Adc_DetectVariant)
 *
 * START-UP CODING (Adc_DetectVariant, 0xBEC7):
 *   Reads channel 0x0B ONCE at boot and classifies the 8-bit value into
 *   discrete windows.  The ONLY output consumed later is the bitmask
 *   g_featureFlags (0x0299) - see the FEAT_* gates spread across the
 *   firmware.  g_variantCode (0x02EC) and g_variantSub (0x02EB) are written
 *   here but are NEVER READ anywhere in the image: dead/diagnostic
 *   leftovers, NOT a consumed "variant number".  (There is therefore no
 *   enumerated list of hardware variants - only the feature bits matter.)
 *   A value outside every window sets g_testMode (0x02EA), which disables
 *   the gated subsystems.
 *
 *   Channel 0x0B = AD11 = PTD3 = pin 32.  On this board (per hardware
 *   inspection) that pin is wired, through series resistors, to the COMMON
 *   EMITTER of the TCUT1350X01 transmissive optical sensor (the scroll-wheel
 *   quadrature encoder).  So the "coding" is a one-shot read of the resting
 *   DC level on that rail; the level (set by the series-resistor network /
 *   which options are populated) selects the feature set.  It is best read
 *   as option/presence coding at power-up, not a stored variant id.
 *   The exact divider topology on that rail is board-level and NOT provable
 *   from the firmware - treated here as the coding input only.
 *
 * Variant_ReadStraps() additionally samples digital strap pins (table at
 * flash 0xC245) and packs them into g_codingByte (used by the LIN
 * identification signals).  So coding = analog window (ch 0x0B) + straps.
 */
#include "app.h"

/* start-up coding results (see file header) */
byte g_codingByte;      /* [0x0298] digital strap code (Variant_ReadStraps)   */
byte g_featureFlags;    /* [0x0299] enabled-feature bitmask - ONLY consumed output */
byte g_variantCode;     /* [0x02EC] WRITTEN BUT NEVER READ - dead/diagnostic  */
byte g_variantSub;      /* [0x02EB] WRITTEN BUT NEVER READ - dead/diagnostic  */
byte g_testMode;        /* [0x02EA] 1 = coding out of range -> gated off      */

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
 * Reads the start-up option coding (ADC window + straps), then continues.
 * ====================================================================== */
void Adc_Init(void)
{
    Adc_DetectVariant();                 /* [0xBEC7] */
    Variant_ReadStraps();                /* [0xBFA7] (reached via jmp 0xBFA7) */
}

/* ======================================================================
 * Adc_DetectVariant  [0xBEC7]
 * Reads the coding channel (0x0B) once and classifies it.  The [lo,hi)
 * bands and their results are exactly those coded in the firmware.  Only
 * g_featureFlags is used afterwards; g_variantCode/g_variantSub are set
 * but never read (kept here to mirror the original code faithfully).
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
        g_featureFlags = 0x08;           /* only FEAT_RESERVED - no subsystem enabled */
    } else if (v >= 0x7C && v < 0x8A) {  /* band 6 */
        g_variantCode  = 8;
        g_variantSub   = 1;
        g_featureFlags = 0x09;
    } else if (v >= 0x8E && v < 0x9E) {  /* band 7 */
        g_variantCode  = 9;
        g_variantSub   = 1;
        g_featureFlags = 0x0F;           /* opt-buttons + heater + scroll (+ reserved 0x08) */
    } else if (v >= 0xA3 && v < 0xB2) {  /* band 8 */
        g_variantCode  = 0x0A;
        g_variantSub   = 1;
        g_featureFlags = 0x0C;           /* scroll (+ reserved 0x08) */
    } else if (v >= 0xB7 && v < 0xC9) {  /* band 9 */
        g_variantCode  = 0x0B;
        g_variantSub   = 1;
        g_featureFlags = 0x0B;           /* opt-buttons + heater (+ reserved 0x08) */
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
