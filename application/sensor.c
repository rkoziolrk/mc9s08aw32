/*
 * sensor.c - ADC analogue front-end configuration
 *            (decompiled from Sensor_Init, 0xA0E6).
 *
 * Configures the ADC1 module: long sample time + bus/2 clock + 8-bit
 * conversions (ADC1CFG = 0x41), software trigger / compare off
 * (ADC1SC2 = 0), and enables the analogue function on the channels used
 * by the firmware via the pin-control registers (APCTL1 = 0x0F enables
 * AD0..AD3; APCTL2/APCTL3 = 0).  The compare value registers are cleared.
 * Individual conversions are then performed on demand by Adc_Read().
 */
#include "app.h"

/* ======================================================================
 * Sensor_Init  [0xA0E6]
 * ====================================================================== */
void Sensor_Init(void)
{
    ADC1CFG = 0x41;     /* ADLPC off, long sample, ADIV=bus/2, 8-bit mode */
    ADC1SC2 = 0x00;     /* software trigger, compare function off          */
    APCTL1  = 0x0F;     /* AD0..AD3 = analogue inputs                       */
    APCTL2  = 0x0F >> 1;/* (original: LSRA of 0x0F = 0x07) AD8..AD10        */
    APCTL3  = 0x00;
    ADC1CVL = 0x00;
    ADC1CVH = 0x00;
}
