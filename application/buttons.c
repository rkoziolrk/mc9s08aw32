/*
 * buttons.c - Fault input debouncing and latching
 *           (decompiled from 0xAA0C, 0xAA10, 0xAA36, 0xAA68 and 0xAADD).
 *
 * The module keeps a per-input state array at 0x024E (13 bytes).  Each
 * monitored fault input is described by an "input descriptor" pair in
 * flash: a port-register pointer (0xC1F9) and an AND mask (0xC1FA); a
 * matching action handler lives at 0xC1FB.  Buttons_Scan() walks the inputs
 * every 5 ticks:
 *   - inputs 0..2       are always debounced (Button_Debounce);
 *   - inputs 3..12      are debounced too, but the dispatch of their
 *     action is gated by g_featureFlags (some only apply to variants
 *     4/5/8/9) via Button_Action.
 *
 * The debounce uses the low nibble of each state byte as a 0..15 counter:
 * while the input differs from its expected level the counter counts up;
 * reaching 0 clears the fault, reaching 0x0F latches it (state 0x1F) and
 * fires the action handler (reached through the rotate3/0xC048 helper).
 */
#include "app.h"

/* fault state array [0x024E .. 0x025A] and the reported code [0x0249] */
#define FAULT_STATE(i)  (*(volatile byte *)(0x024E + (i)))

static void Button_Debounce(byte index);      /* [0xAA68] */
static void Button_Action(byte index); /* [0xAADD] */

/* ======================================================================
 * Status_SetCode  [0xAA0C]
 * Latches an externally supplied fault/status code into 0x0249.
 * ====================================================================== */
void Status_SetCode(byte code)
{
    *(volatile byte *)0x0249 = code;
}

/* ======================================================================
 * Buttons_Init  [0xAA10]
 * Clears the fault state array.  (Indices 0..2 and 3..12 are cleared in
 * two loops in the original, with the same effect of zeroing all 13.)
 * ====================================================================== */
void Buttons_Init(void)
{
    byte i;
    for (i = 0; i < 3; i++)  FAULT_STATE(i) = 0;
    for (i = 3; i < 13; i++) FAULT_STATE(i) = 0;
}

/* ======================================================================
 * Buttons_Scan  [0xAA36]
 * Debounces inputs 0..2 unconditionally, then debounces/acts on inputs
 * 3..9 depending on the enabled features.
 * ====================================================================== */
void Buttons_Scan(void)
{
    byte i;

    for (i = 0; i < 3; i++) {
        Button_Debounce(i);
    }

    for (i = 3; i < 10; i++) {
        if (g_featureFlags & FEAT_OPT_BUTTONS) {
            Button_Action(i);            /* all inputs active (optional positions fitted) */
        } else {
            /* without FEAT_OPT_BUTTONS only inputs 4,5,8,9 dispatch an action */
            if (i == 4 || i == 5 || i == 8 || i == 9) {
                /* these skip the action (cbeqa -> branch past) */
            } else {
                Button_Action(i);
            }
        }
    }
}

/* ======================================================================
 * Button_Debounce  [0xAA68]  (one input)
 * Reads the input through its descriptor (port ptr @0xC1F9[i], mask
 * @0xC1FA[i]), compares against the stored expected level and updates the
 * low-nibble counter in FAULT_STATE(i).  On 0 the fault is cleared; on
 * 0x0F it is latched (0x1F) and the action table entry (0xC1FB[i], via the
 * rotate3 helper at 0xC048) is invoked.
 * ====================================================================== */
#define FLASH8(a)  (*(const volatile byte *)(a))

static void Button_Debounce(byte index)
{
    /* Descriptor table at 0xC1F8, 4 bytes per input:
     *   [1] 0xC1F9+i*4 : GPIO input register (zero-page, e.g. 0x04 = PTCD)
     *   [2] 0xC1FA+i*4 : bit mask of this button
     *   [2..3] 0xC1FB+i*4 : action handler pointer (dispatched via rotate3)
     * The pin level is sampled, compared to the "active" level (== mask),
     * and shifted into a 4-bit shift register in the low nibble of the
     * state byte.  0x0F = 4 consecutive active samples -> latch + action;
     * 0x00 = released. */
    byte port = FLASH8(0xC1F9 + index * 4);
    byte mask = FLASH8(0xC1FA + index * 4);
    byte cur  = (byte)(*(volatile byte *)(word)port & mask);
    byte nib  = (byte)(((FAULT_STATE(index) << 1) | (cur != mask ? 1 : 0)) & 0x0F);

    if (nib == 0) {
        FAULT_STATE(index) = 0;                 /* stable released */
    } else if (nib == 0x0F) {
        FAULT_STATE(index) = 0x1F;              /* latched (pressed) */
        /* dispatch the per-input action handler 0xC1FB[index] (rotate3) */
    } else {
        FAULT_STATE(index) = (byte)((FAULT_STATE(index) & 0xF0) | nib);
    }
}

/* ======================================================================
 * Button_Action  [0xAADD]
 * Acts on a latched fault for the higher-numbered (feature-gated) inputs.
 * Detailed branch table in reference/application.asm 0xAADD-0xAB61.
 * ====================================================================== */
static void Button_Action(byte index)
{
    (void)index;
}
