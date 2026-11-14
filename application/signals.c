/*
 * signals.c - LIN publish-signal preparation (application -> LIN image)
 *             (decompiled from LinSignals_Init 0xAC81 and
 *              LinSignals_Refresh 0xACB7).
 *
 * Maintains the block of "status" variables (0x025C..0x026D) that are
 * later packed into the LIN publish frame.  LinSignals_Init() clears them
 * and sets the "node present" flag (0x0277).  LinSignals_Refresh() runs
 * the fault debouncer and then derives the per-channel status and the
 * two special status bits from the latched input states.
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))

/* ======================================================================
 * LinSignals_Init  [0xAC81]
 * Clears all published status variables and marks the node present.
 * ====================================================================== */
void LinSignals_Init(void)
{
    R8(0x0266) = 0; R8(0x0267) = 0; R8(0x0268) = 0; R8(0x0269) = 0;
    R8(0x0264) = 0; R8(0x026A) = 0; R8(0x026C) = 0; R8(0x026D) = 0;
    R8(0x026B) = 0; R8(0x0265) = 0; R8(0x0260) = 0; R8(0x0261) = 0;
    R8(0x025E) = 0; R8(0x025F) = 0; R8(0x025C) = 0; R8(0x025D) = 0;
    R8(0x0277) = 1;                            /* node present */
}

/* ======================================================================
 * LinSignals_Refresh  [0xACB7]
 * Recomputes the publishable status signals.  Runs the fault debouncer 5
 * times (Fault_Task), then for each of the 6 input channels forces a
 * default status (0x03) when the channel's aux byte is zero, and maps the
 * two latched flags (0x02BD/0x02BE) into their status bits.
 * ====================================================================== */
void LinSignals_Refresh(void)
{
    byte i;

    R8(0x0263) = 0;
    R8(0x0262) = 0;

    for (i = 0; i < 5; i++) {
        Fault_Task();                          /* [0xAA36] */
    }

    for (i = 0; i < 6; i++) {
        if (R8(0x02C6 + i * 2) == 0) {
            R8(0x02C5 + i * 2) = 0x03;         /* default channel status */
        }
    }

    if (R8(0x02BD) == 1) {                     /* latched flag A */
        R8(0x0263) = 1;
        R8(0x025F) = 1;
        R8(0x025E) = 0;
    }
    if (R8(0x02BE) == 1) {                     /* latched flag B */
        R8(0x0262) = 1;
        R8(0x025D) = 1;
        R8(0x025C) = 0;
    }
    /* remaining mapping (0x0260/0x0261 etc.) continues in
     * reference/application.asm 0xAD07-0xAD35. */
}

/* ======================================================================
 * Signals_Task  [0xAE36]   (called from the 25-tick task)
 * Maintains the "time since event" counters attached to the published
 * status signals: some count down to zero (0x0267, 0x026B) and some count
 * up with saturation at 0xFFFF (0x0268, 0x026C, and 0x025C/0x025E when
 * FEAT_BIT0 is set).  These counters time the LIN status/age signals.
 * The full set continues in reference/application.asm 0xAE36-0xAF20.
 * ====================================================================== */
void Signals_Task(void)
{
    word v;

    if (R8(0x0267) != 0) R8(0x0267)--;          /* down-counter */
    if (R8(0x026B) != 0) R8(0x026B)--;

    v = (word)(((word)R8(0x0268) << 8) + R8(0x0269));   /* up, saturating */
    if (v != 0 && v < 0xFFFF) { v++; R8(0x0268) = (byte)(v >> 8); R8(0x0269) = (byte)v; }

    v = (word)(((word)R8(0x026C) << 8) + R8(0x026D));
    if (v != 0 && v < 0xFFFF) { v++; R8(0x026C) = (byte)(v >> 8); R8(0x026D) = (byte)v; }

    if (g_featureFlags & FEAT_BIT0) {
        v = (word)(((word)R8(0x025C) << 8) + R8(0x025D));
        if (v != 0 && v < 0xFFFF) { v++; R8(0x025C) = (byte)(v >> 8); R8(0x025D) = (byte)v; }
        v = (word)(((word)R8(0x025E) << 8) + R8(0x025F));
        if (v != 0 && v < 0xFFFF) { v++; R8(0x025E) = (byte)(v >> 8); R8(0x025F) = (byte)v; }
    }
    /* remaining counters: see reference/application.asm 0xAE8B-0xAF20. */
}
