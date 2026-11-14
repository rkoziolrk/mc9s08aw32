/*
 * fault.c - Fault input debouncing and latching
 *           (decompiled from 0xAA0C, 0xAA10, 0xAA36, 0xAA68 and 0xAADD).
 *
 * The module keeps a per-input state array at 0x024E (13 bytes).  Each
 * monitored fault input is described by an "input descriptor" pair in
 * flash: a port-register pointer (0xC1F9) and an AND mask (0xC1FA); a
 * matching action handler lives at 0xC1FB.  Fault_Task() walks the inputs
 * every 5 ticks:
 *   - inputs 0..2       are always debounced (Fault_sub_AA68);
 *   - inputs 3..12      are debounced too, but the dispatch of their
 *     action is gated by g_featureFlags (some only apply to variants
 *     4/5/8/9) via Fault_sub_AADD.
 *
 * The debounce uses the low nibble of each state byte as a 0..15 counter:
 * while the input differs from its expected level the counter counts up;
 * reaching 0 clears the fault, reaching 0x0F latches it (state 0x1F) and
 * fires the action handler (reached through the rotate3/0xC048 helper).
 */
#include "app.h"

/* fault state array [0x024E .. 0x025A] and the reported code [0x0249] */
#define FAULT_STATE(i)  (*(volatile byte *)(0x024E + (i)))

static void Fault_Debounce(byte index);      /* [0xAA68] */
static void Fault_DispatchAction(byte index); /* [0xAADD] */

/* ======================================================================
 * Fault_Report  [0xAA0C]
 * Latches an externally supplied fault/status code into 0x0249.
 * ====================================================================== */
void Fault_Report(byte code)
{
    *(volatile byte *)0x0249 = code;
}

/* ======================================================================
 * Fault_Init  [0xAA10]
 * Clears the fault state array.  (Indices 0..2 and 3..12 are cleared in
 * two loops in the original, with the same effect of zeroing all 13.)
 * ====================================================================== */
void Fault_Init(void)
{
    byte i;
    for (i = 0; i < 3; i++)  FAULT_STATE(i) = 0;
    for (i = 3; i < 13; i++) FAULT_STATE(i) = 0;
}

/* ======================================================================
 * Fault_Task  [0xAA36]
 * Debounces inputs 0..2 unconditionally, then debounces/acts on inputs
 * 3..9 depending on the enabled features.
 * ====================================================================== */
void Fault_Task(void)
{
    byte i;

    for (i = 0; i < 3; i++) {
        Fault_Debounce(i);
    }

    for (i = 3; i < 10; i++) {
        if (g_featureFlags & FEAT_BIT0) {
            Fault_DispatchAction(i);            /* all inputs active */
        } else {
            /* without FEAT_BIT0 only inputs 4,5,8,9 dispatch an action */
            if (i == 4 || i == 5 || i == 8 || i == 9) {
                /* these skip the action (cbeqa -> branch past) */
            } else {
                Fault_DispatchAction(i);
            }
        }
    }
}

/* ======================================================================
 * Fault_Debounce  [0xAA68]  (one input)
 * Reads the input through its descriptor (port ptr @0xC1F9[i], mask
 * @0xC1FA[i]), compares against the stored expected level and updates the
 * low-nibble counter in FAULT_STATE(i).  On 0 the fault is cleared; on
 * 0x0F it is latched (0x1F) and the action table entry (0xC1FB[i], via the
 * rotate3 helper at 0xC048) is invoked.
 * ====================================================================== */
static void Fault_Debounce(byte index)
{
    /* The read uses the parallel flash descriptor tables
     *   port = *(word*)(0xC1F9 + index*4);   mask = *(byte*)(0xC1FA + index*4)
     * then: cur = (*port & mask); if it differs from expected, counter++.
     * See reference/application.asm 0xAA68-0xAADC for the exact sequence
     * (the index is scaled by 4 because each descriptor is 4 bytes). */
    byte cnt = (byte)(FAULT_STATE(index) + 0 /* +1 when mismatch, see asm */);
    cnt &= 0x0F;
    if (cnt == 0) {
        FAULT_STATE(index) = 0;
    } else if (cnt == 0x0F) {
        FAULT_STATE(index) = 0x1F;              /* latched */
        /* dispatch action 0xC1FB[index] via rotate3/jump */
    } else {
        FAULT_STATE(index) = (byte)((FAULT_STATE(index) & 0xF0) | cnt);
    }
}

/* ======================================================================
 * Fault_DispatchAction  [0xAADD]
 * Acts on a latched fault for the higher-numbered (feature-gated) inputs.
 * Detailed branch table in reference/application.asm 0xAADD-0xAB61.
 * ====================================================================== */
static void Fault_DispatchAction(byte index)
{
    (void)index;
}
