/*
 * util.c - small shared helpers
 *          (Delay_Loop decompiled from 0xB653).
 */
#include "app.h"

/* ======================================================================
 * Delay_Loop  [0xB653]
 * Calibrated busy-wait.  The original decrements H:X (seeded from the A
 * register, high byte cleared) to zero, padded with BRN instructions so
 * each iteration takes a fixed number of bus cycles.  Used for the ADC
 * settling delay and various short hardware timings.
 * ====================================================================== */
byte Delay_Loop(word count)
{
    volatile word i = count & 0x00FF;    /* original only uses the low byte */
    while (i != 0) {
        i--;                             /* BRN padding in the original = NOPs */
    }
    return 0;
}
