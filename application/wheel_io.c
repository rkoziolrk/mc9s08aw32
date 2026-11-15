/*
 * wheel_io.c - Steering-wheel I/O: button-ladder scan, scroll/roll wheel,
 *              and backlight (PWM) dimming control.
 *              (decompiled from 0xA12E, 0xA1E6, 0xA256, 0xA694, 0xA6F9,
 *               0xA719, 0xA5B5, 0xA99E, 0xA9A9 and helpers; see DEVICE.md.)
 *
 * This is the largest subsystem.  The function names are the real ones:
 *   Backlight_*  - the dimming state machine (brightness ramp toward the
 *                  commanded level, gated by the supply window)
 *   Scan_*       - the 1 ms button-ladder / scroll sampling + PWM tick
 *   Ladder_*     - analogue button-ladder reads and plausibility checks
 *   Output_*     - the physical output stage (enable / stop / self-test)
 *   Ramp_Limit   - the slew-rate limiter (backlight fade, supply filter)
 * The inner per-state arithmetic and the ladder compare table are intricate
 * fixed-point code cross-referenced to reference/application.asm.
 *
 * Active only on variants whose feature flags contain the scroll/backlight
 * bit (0x04); the application disables these tasks in g_testMode.
 *
 * Key RAM:
 *   0x02B2  backlight output level / PWM duty request
 *   0x0244  current scan position       0x0246/0x0247  position window
 *   0x0245  scan-active flag             0x0241/0x0242  ladder references
 *   0x022F..0x023D  controller working set (ramp, target, flags)
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))
#define FLASH8(a) (*(const volatile byte *)(a))

extern void Output_Stop(void);   /* [0xA874] set up the H-bridge/PWM pins */
extern byte Ladder_Reset(void);   /* [0xA88F] read end-stop / hall inputs   */
extern byte Output_SelfTest(void);   /* [0xA8B6] self-test / stall check       */
extern byte Output_StallCheck(void);   /* [0xA91B] self-test / stall check       */
extern byte Ladder_ReadRef(void);   /* [0xA957] drive the output stage        */

byte g_backlightLevel AT(0x02B2);       /* [0x02B2] requested output level */

/* ======================================================================
 * Backlight_Init  [0xA12E]
 * Clears the controller accumulators (0x02B4/0x02B5) and sets the "idle"
 * state flag (0x02B3 = 1).
 * ====================================================================== */
void Backlight_Init(void)
{
    R8(0x02B4) = 0;
    R8(0x02B5) = 0;
    R8(0x02B3) = 1;
}

/* ======================================================================
 * Backlight_Start  [0xA1E6]
 * Zeroes the whole controller working set (0x022F..0x023D) and runs the
 * initial self-tests (Output_Stop/A91B/A8B6).  Depending on their
 * results it records the start-up fault code in 0x02A8 and flags the
 * controller state (0x029B/0x029C/0x023B/0x023C).  Full branch logic:
 * reference/application.asm 0xA1E6-0xA255.
 * ====================================================================== */
void Backlight_Start(void)
{
    byte i;
    for (i = 0x2F; i <= 0x3D; i++) {
        R8(0x0200 + i) = 0;             /* clear 0x022F..0x023D */
    }
    Output_Stop();
    if (Output_StallCheck() == 0) {        /* self-test A failed */
        R8(0x02A8) = 0x0B;
        R8(0x029B) = 1;
        R8(0x029C) = 1;
        R8(0x023B) = 0x0B;
    }
    if (Output_SelfTest() == 0) {        /* self-test B failed */
        R8(0x02A8) = 0x07;
        R8(0x029B) = 1;
        R8(0x023C) = 1;
        R8(0x023B) = 0x0B;
    }
    /* ... remaining start-up sequencing: see asm 0xA248-0xA25x ... */
}

/* ======================================================================
 * Backlight_Task  [0xA256]   (DEVICE: backlight dimming state machine)
 *
 * The 10-tick control step.  Really drives the button BACKLIGHT: a 12-state
 * machine (switch on g_ctrlState = 0x023B, via switch_jump) that ramps the
 * backlight brightness toward the commanded level, applying the dimming
 * level and option flags received over LIN and the per-mode brightness
 * curve stored in the configuration.
 *
 * State table (0x023B): 0->A299 1->A2A4 2->A305 3->A35C 4->A3AE 5->A3FE
 *                       6->A446 7->A482 8->A47F 9->A4F4 10->A533 11->A570
 * Key variables:
 *   0x022B:0x022C  16-bit brightness ramp counter / dwell timer (Backlight_StepTimer)
 *   0x0229         target brightness (from g_cfg[0x32 + mode])
 *   0x0291..0x0296 decoded command bits (level/mode/flags, see lin_signals.c)
 *   g_supplyVoltage via a lookup (0xA64E) gates the brightness
 *   Output_Stop turns the backlight output off
 * Full per-state bodies: reference/application.asm 0xA256-0xA6F8.
 * ====================================================================== */
/* ---- state-machine variables (absolute addresses preserved) ---------- */
#define CS        R8(0x023B)          /* current state 0..11            */
#define RAMP_HI   R8(0x022B)          /* 16-bit ramp/dwell timer hi     */
#define RAMP_LO   R8(0x022C)
#define RAMP      ((word)((RAMP_HI << 8) | RAMP_LO))
#define CMD_POS_LO   R8(0x0291)
#define CMD_POS_HI   R8(0x0292)
#define CMD_MODE     R8(0x0293)
#define CMD_FLAG_A   R8(0x0294)
#define CMD_FLAG_B   R8(0x0295)
#define CMD_FLAG_C   R8(0x0296)

void Backlight_StepTimer(void);   /* [0xA25A] forward decl */
static void Backlight_ClearRamp(void) { RAMP_HI = 0; RAMP_LO = 0; }   /* [0xA5AD] */

/* [0xA64E] 1 if the supply voltage is inside the operating window
 * [cfg 0x016C .. 0x016E] */
static byte Supply_InWindow(void)
{
    if (R8(0x016E) >= g_supplyVoltage && g_supplyVoltage >= R8(0x016C)) {
        return 1;
    }
    return 0;
}

/* [0xA608] low-voltage edge debounce (counts 0x0235 to 2 once v < cfg 0x016E) */
static byte Supply_LowEdgeDeb(void)
{
    if (g_supplyVoltage >= R8(0x016E)) return 0;
    if (R8(0x0235) >= 2) R8(0x0235) = 0; else R8(0x0235)++;
    return 1;
}

/* [0xA62B] high-voltage edge debounce (counts 0x0236 once v > cfg 0x016C) */
static byte Supply_HighEdgeDeb(void)
{
    if (g_supplyVoltage <= R8(0x016C)) return 0;
    if (R8(0x0236) >= 2) R8(0x0236) = 0; else R8(0x0236)++;
    return 1;
}

/* [0xA669] on a debounced voltage edge, branch to the low/high-voltage states */
static void Backlight_CheckVoltEdges(void)
{
    if (Supply_HighEdgeDeb() == 1 && R8(0x0236) == 0) CS = 9;
    if (Supply_LowEdgeDeb()  == 1 && R8(0x0235) == 0) CS = 10;
}

/* [0xA894] button-ladder plausibility: sets 0x0240 bit1, and if the ladder
 * ratio 0x0241/0x0242 >= 8 clears it (implausible). Returns 0x0240. */
static byte Ladder_PlausCheck(void)
{
    R8(0x0240) |= 0x02;
    if (R8(0x0242) != 0 && (byte)(R8(0x0241) / R8(0x0242)) >= 0x08) {
        R8(0x0240) &= (byte)~0x02;
    }
    return R8(0x0240);
}

/* [0xA79F]/[0xA7FA] drive the backlight output to a brightness level
 * (threshold 0x1A / 0x15); non-zero target arms the PWM output, zero stops it.
 * The two entries differ only in the window value (0x19 vs 0x14). */
static void Backlight_SetLevel(byte level, byte window, byte thresh)
{
    if (level < thresh) return;                 /* below the minimum */
    if (level != 0) {
        R8(0x0245) = 1;                         /* output active */
        R8(0x0247) = R8(0x0244 + 1);            /* (saved arg) */
        R8(0x0246) = window;
        R8(0x0244) = 0;
        R8(0x0008) |= 0x04;                     /* enable backlight pin */
        R8(0x000A) &= (byte)~0x10;
        R8(0x023F) = 0;
        R8(0x029A) = 0;
    } else {
        R8(0x0245) = 0;                         /* output off */
        R8(0x0008) &= (byte)~0x04;
    }
}
#define Backlight_On19(lvl)  Backlight_SetLevel((lvl), 0x19, 0x1A)   /* [0xA79F] */
#define Backlight_On14(lvl)  Backlight_SetLevel((lvl), 0x14, 0x15)   /* [0xA7FA] */

/* [0xA855] enter the dwell phase: output off, re-arm the dwell count 0x0243 */
static void Backlight_Dwell(void)
{
    R8(0x0245) = 0;
    R8(0x0008) &= (byte)~0x04;
    R8(0x000A) &= (byte)~0x10;
    R8(0x0243) = 0x04;
    R8(0x023F) = 0;
    R8(0x029A) = 0;
}

/* ======================================================================
 * Backlight_Task  [0xA256]   DEVICE: backlight dimming / button-feedback FSM.
 * Faithful transcription of the 12-state machine (0xA270-0xA6F8).  Each
 * state gates on the supply-voltage window (Supply_InWindow), the decoded
 * dimming command (CMD_*), and the ramp/dwell timer, then drives the
 * backlight output and advances g_ctrlState (CS).
 * ====================================================================== */
void Backlight_Task(void)
{
    byte r;

    Backlight_StepTimer();                                /* [0xA25A] advance dwell timer */

    if (CS >= 0x0C) { Output_Stop(); CS = 0; return; }   /* [0xA270->A5A3] guard */

    switch (CS) {

    case 0:                                     /* LA299: off / init */
        Output_Stop();
        CS = 1;
        return;

    case 1:                                     /* LA2A4: idle, await command */
        if (Supply_InWindow() != 1) { Output_Stop(); Backlight_CheckVoltEdges(); return; }
        if (CMD_FLAG_B == 1 && CMD_FLAG_A == 0 && R8(0x029B) == 0) {
            if (CMD_POS_LO != 0) {
                Backlight_On19((byte)(CMD_POS_HI + 0x0A));
            } else {
                RAMP_LO = 0x0F; RAMP_HI = 0;
            }
            CS = 2;
            Backlight_ClearRamp();
            return;
        }
        /* LA2E2 */
        if (CMD_FLAG_C == 1 && R8(0x022A) == 0) CS = 7;
        if (CMD_FLAG_C != 0) return;
        R8(0x022A) = 0;
        return;

    case 2:                                     /* LA305: ramp toward target */
        if (Supply_InWindow() != 1) { Output_Stop(); Backlight_CheckVoltEdges(); return; }
        if (R8(0x029B) != 0) { CS = 0x0B; Output_Stop(); return; }  /* LA348 fault */
        if (RAMP < 0x000F) {
            /* still within the initial dwell */
        }
        /* LA32A: fetch the per-mode brightness from config, apply it */
        R8(0x0229) = g_cfg.raw[0x32 + (CMD_MODE & 0x0F)];
        Backlight_On14(R8(0x0229));
        Backlight_ClearRamp();
        CS = 3;
        return;

    case 3:                                     /* LA35C: holding at level */
        r = Supply_InWindow();
        if (r != 1) { Output_Stop(); Backlight_CheckVoltEdges(); return; }
        /* compare the commanded level 0x0151 (<<2) against the ramp timer */
        {
            word lvl = (word)(R8(0x0151) << 2);
            if ((int)(lvl - RAMP) >= 0 && R8(0x0151) != 0) { /* keep holding */ }
            if (CMD_FLAG_B != 0 && CMD_FLAG_A != 0 && (--R8(0x029B)) != 0) {
                return;                         /* loop back into state 3 */
            }
        }
        Output_Stop();
        Delay_Loop(0xFA);
        Backlight_Dwell();                      /* [0xA855] */
        Backlight_ClearRamp();
        CS = 4;
        return;

    case 4:                                     /* LA3AE: dwell + plausibility */
        if (Supply_InWindow() != 1) { Backlight_CheckVoltEdges(); return; }
        r = Ladder_PlausCheck();                  /* [0xA894] */
        if (r != 0) {
            if (r == 1) { Output_Stop(); Backlight_CheckVoltEdges(); return; }
            if (r == 2) R8(0x023D) = 1;
            CS = 0x0B; Output_Stop();        /* implausible -> fault */
            return;
        }
        if (RAMP < 0x0032) { Output_Stop(); CS = 6; return; }   /* LA3D8 */
        if (CMD_FLAG_B != 0) { CS = 6; return; }
        CS = 5;
        return;

    case 5:                                     /* LA3FE: step the dimming */
        if (Supply_InWindow() != 1) { Output_Stop(); Backlight_CheckVoltEdges(); return; }
        if (CMD_FLAG_B != 1) {                  /* LA42B */
            if (RAMP < 0x0032) return;
            Output_Stop();
            CS = 0;
            return;
        }
        Output_Stop();
        Delay_Loop(0xFA);
        Backlight_On14((byte)(CMD_POS_HI + 0x0A));
        Backlight_ClearRamp();
        CS = 2;
        return;

    case 6:                                     /* LA446: wait for release */
        if (Supply_InWindow() != 1) { Output_Stop(); Backlight_CheckVoltEdges(); return; }
        if (CMD_FLAG_B == 0) { CS = 0; Output_Stop(); return; }
        if (CMD_FLAG_C == 1 && R8(0x022A) == 0) CS = 7;
        if (CMD_FLAG_C != 0) return;
        R8(0x022A) = 0;
        return;

    case 7:                                     /* LA482: self-test / special */
        if (Supply_InWindow() != 1) { Backlight_CheckVoltEdges(); return; }
        if (R8(0x023C) == 0) {
            if (Output_SelfTest() != 0) {        /* drive self-test ok */
                if (R8(0x023A) == 2) {          /* LA49E */
                    Output_Stop(); CS = 0x0B;
                    R8(0x029B) = 1; R8(0x023A) = 0; R8(0x023C) = 1;
                    R8(0x02A8) = 7;
                } else { R8(0x023A)++; }
            }
        }
        r = Ladder_PlausCheck();
        if (r & 0x02) { R8(0x023D) = 1; Output_Stop(); CS = 0x0B; }
        if (r == 0) { Output_Stop(); CS = 6; R8(0x023C) = 0; }
        R8(0x022A) = 1;
        return;

    case 8:                                     /* LA47F: (shares state 7 exit) */
        Backlight_CheckVoltEdges();
        return;

    case 9:                                     /* LA4F4: low-voltage handling */
        if (g_supplyVoltage < R8(0x016D)) { Backlight_CheckVoltEdges(); return; }
        if (g_supplyVoltage < R8(0x016E)) {     /* LA51B */
            if (R8(0x0231) >= 2) { R8(0x0231) = 0; CS = 6; }
            else R8(0x0231)++;
            return;
        }
        if (R8(0x0232) >= 2) { R8(0x0232) = 0; CS = 0x0A; }   /* LA501 */
        else R8(0x0232)++;
        return;

    case 10:                                    /* LA533: high-voltage handling */
        if (g_supplyVoltage <= R8(0x016F)) return;
        if (g_supplyVoltage < R8(0x016C)) {     /* LA558 */
            if (R8(0x0233) >= 2) { R8(0x0233) = 0; CS = 9; }
            else R8(0x0233)++;
            return;
        }
        if (R8(0x0234) >= 2) { R8(0x0234) = 0; CS = 6; }      /* LA540 */
        else R8(0x0234)++;
        return;

    default:                                    /* case 11, LA570: fault recovery */
        if ((--R8(0x029C)) != 0) { Output_Stop(); return; }
        if (Output_StallCheck() != 0) return;      /* stuck-button / short check */
        if (R8(0x0237) == 2) {
            R8(0x02A8) = 0; R8(0x029B) = 0; R8(0x029C) = 0;
            CS = 6; R8(0x0237) = 0;
        } else {
            R8(0x0237)++;
        }
        return;
    }
}

/* Backlight_StepTimer [0xA25A] - count the 16-bit ramp/dwell timer 0x022B:0x022C up
 * to 0xFFFF, then wrap to 0 (the per-state dwell between brightness steps). */
void Backlight_StepTimer(void)
{
    word t = (word)((R8(0x022B) << 8) | R8(0x022C));
    if (t < 0xFFFF) {
        t++;
        R8(0x022B) = (byte)(t >> 8);
        R8(0x022C) = (byte)t;
    } else {
        R8(0x022B) = 0;
        R8(0x022C) = 0;
    }
}

/* ======================================================================
 * Backlight_SupplyStep  [0xA13A]
 * Supply-voltage compensation of the backlight level, called from
 * Supply_Task after each supply reading.  It computes a 16-bit compensated
 * brightness into 0x02B4:0x02B5 (the value the PWM stage uses) from the
 * requested level 0x02B2 and the measured g_supplyVoltage, and sets the
 * "updated" flag 0x02B3.
 *
 * Two modes, selected by cfg[0x4A] (0x016A):
 *  - mode != 1 (the scaling path): only when supply >= cfg[0x4C] (0x016C)
 *    or the requested level >= 3.  brightness = level * ((supply*0x5A6 -
 *    0x1A) / 0x40); if that 32-bit product reaches the limit at flash
 *    0xC1F5 it is clamped to 0xC8.  (Fixed-point via mul16/div16/cmp32;
 *    exact sequence reference/application.asm 0xA14F-0xA199.)
 *  - mode == 1 (the doubling path, 0xA19B): gated by 0x02B1 and the
 *    cfg[0x4D] (0x016D) supply threshold; brightness = level << 1.
 * ====================================================================== */
void Backlight_SupplyStep(void)
{
    byte  level = R8(0x02B2);
    word  bright;

    R8(0x02B3) = 0;

    if (g_supplyVoltage >= R8(0x016C) || level >= 3) {
        if (R8(0x016A) != 1) {                     /* scaling path */
            /* compensated = level * ((supply*0x5A6 - 0x1A) / 0x40) */
            word factor = (word)((mul16(g_supplyVoltage, 0x05A6) - 0x1A) / 0x40);
            bright = mul16(level, factor);
            /* 32-bit limit at flash 0xC1F5 -> clamp high to 0xC8 */
            if (bright >= (word)((FLASH8(0xC1F5) << 8) | FLASH8(0xC1F6))) {
                R8(0x02B4) = 0xC8;
                R8(0x02B5) = 0x00;
            } else {
                R8(0x02B4) = (byte)(bright >> 8);
                R8(0x02B5) = (byte)bright;
            }
        } else {                                   /* mode 1: doubling path */
            if (R8(0x02B1) != 1 || g_supplyVoltage >= R8(0x016D)) {
                R8(0x02B4) = (byte)(level << 1);
                R8(0x02B5) = 0x00;
                R8(0x02B1) = 0;
            }
        }
    }
    R8(0x02B3) = 1;
}

/* ======================================================================
 * Backlight_SlowTask  [0xA694]
 * Slow controller housekeeping (10-tick slot 10): recomputes the position
 * window and refreshes the output enable. See asm 0xA694-0xA6F8.
 * ====================================================================== */
void Backlight_SlowTask(void)
{
}

/* ======================================================================
 * BacklightOut_Init  [0xA99E]
 * Clears the output level, reports the initial status (Status_SetCode(1))
 * and stops the TPM1-CH2 output (Diag_StopTestOutput).
 * ====================================================================== */
void BacklightOut_Init(void)
{
    g_backlightLevel = 0;
    Status_SetCode(1);
    /* jmp Diag_sub_B620 - stop the test output (see diag.c) */
}

/* ======================================================================
 * BacklightOut_Task  [0xA9A9]
 * Translates the decoded command (on/off 0x028F, level 0x028E) into the
 * backlight output level 0x02B2, honouring the function-fault flag and the
 * special 0x7F "hold" / 0x50 "fault safe" levels.  For the PWM output
 * variant (g_outputVariant != 0) it takes the alternate path.  Full
 * decision tree: reference/application.asm 0xA9A9-0xA9F9.
 * ====================================================================== */
void BacklightOut_Task(void)
{
    if (g_outputVariant != 0) {
        /* PWM-output variant path (asm LA9F4) */
        return;
    }
    if (R8(0x028F) == 0) {                      /* command = ON */
        if (R8(0x028E) != 0x7F && R8(0x0249) == 0) {
            byte lvl = R8(0x028E);
            if (lvl < 0x65) lvl = 0x64;
            g_backlightLevel = lvl;
        }
    } else {                                    /* command = OFF */
        if (g_funcFault != 0) {
            g_backlightLevel = 0x50;                /* safe level */
            R8(0x0008) |= 0x01;                 /* enable brake pin */
        }
    }
}

/* ======================================================================
 * Scan_Init  [0xA6F9]
 * Resets the position tracking (0x0241..0x0247) and runs the pin setup.
 * ====================================================================== */
void Scan_Init(void)
{
    R8(0x0247) = 0;
    R8(0x0246) = 0;
    R8(0x0244) = 0;
    R8(0x0243) = 0;
    R8(0x0241) = 1;
    R8(0x0242) = 0xFF;
    R8(0x0245) = 0;
    Ladder_Reset();
    Output_Stop();
}

/* ======================================================================
 * Scan_Isr  [0xA719]   (called every 1 ms from Isr_Tpm2Ch0)
 * While a scan is active (0x0245 != 0) it compares the current scan position
 * (0x0244) against the window edges (0x0246/0x0247) and drives the
 * direction / brake outputs (PTED bits via the 0x0008/0x000A control
 * registers) accordingly, stopping at the end stops.  Full compare logic:
 * reference/application.asm 0xA719-0xA7...
 * ====================================================================== */
INTERRUPT void Scan_Isr(void)
{
    if (R8(0x0245) == 0) {
        return;                                 /* not moving */
    }
    if (R8(0x0244) >= R8(0x0246)) {
        if (R8(0x0244) >= R8(0x0247)) {
            R8(0x0008) |= 0x04;                 /* past upper edge */
        } else {
            R8(0x0008) &= (byte)~0x04;
        }
        R8(0x000A) &= (byte)~0x10;
    }
    /* lower-edge handling and step counting continue at asm LA740. */
}

/* ======================================================================
 * Scan_Task  [0xA5B5]
 * Periodic position task (10-tick slot 10): updates the commanded window
 * from the LIN position command and arms a move.  See asm 0xA5B5-0xA6F8.
 * ====================================================================== */
void Scan_Task(void)
{
}

/* ======================================================================
 * Device helper routines (previously referenced; now reconstructed).
 * ====================================================================== */

/* Output_Stop [0xA874] - stop the H-bridge drive and clear the move. */
void Output_Stop(void)
{
    R8(0x0245) = 0;                 /* clear "moving" flag        */
    R8(0x0008) &= (byte)~0x04;      /* bridge enable pin low      */
    R8(0x000A) &= (byte)~0x10;      /* PWM/control pin low        */
    R8(0x023F) = 1;
    R8(0x029A) = 1;
}

/* Ladder_Reset [0xA88F] - clear the end-stop/limit state. */
byte Ladder_Reset(void)
{
    R8(0x0240) = 0;
    return 0;
}

/* Output_StallCheck [0xA91B] - stall / over-current check.
 * Reads the ladder/supply current (ADC ch 0x0A) and feedback (ch 2); if current/feedback
 * >= 7 it flags a stall (0x0240 bit2) and returns 0, otherwise returns 1. */
byte Output_StallCheck(void)
{
    byte current  = Adc_Read(0x0A);
    byte feedback = Adc_Read(0x02);

    R8(0x0240) &= (byte)~0x05;
    if (feedback != 0) {
        if ((byte)(current / feedback) >= 0x07) {
            R8(0x0240) |= 0x04;         /* stall / over-current */
            return 0;
        }
    }
    return 1;
}

/* Ladder_ReadRef [0xA957] - sample the end-stop reference level.
 * Reads the feedback channel (ch 2) three times with delays and stores the
 * running maximum in 0x0242 (the end-stop threshold). */
byte Ladder_ReadRef(void)
{
    byte a, b;
    R8(0x0105) = Adc_Read(0x02);
    Delay_Loop(R8(0x0170));
    R8(0x0106) = Adc_Read(0x02);
    Delay_Loop(R8(0x0171));
    a = R8(0x0105); b = R8(0x0106);
    if (a > b) b = a;
    R8(0x0106) = b;
    a = Adc_Read(0x02);
    R8(0x0105) = a;
    if (a > b) b = a;
    R8(0x0242) = b;
    return b;
}

/* Output_SelfTest [0xA8B6] - output self-test.
 * Briefly energises the bridge, measures the ladder/supply current (ADC ch 0x0A) and
 * feedback (ch 2) and checks the current/feedback ratio against a minimum
 * (0x12).  A ratio below the threshold (or no feedback) is a fault: it
 * clears 0x0240 bit0 and returns 0.  Always stops the drive (Output_Stop)
 * before returning. */
byte Output_SelfTest(void)
{
    byte current, ok = 1;

    R8(0x0008) |= 0x04;                 /* bridge enable */
    R8(0x000A) &= (byte)~0x10;
    current = Adc_Read(0x0A);
    Delay_Loop(0xF0);
    R8(0x0241) = Adc_Read(0x02);        /* feedback */
    R8(0x0240) |= 0x01;

    if (R8(0x0241) != 0) {
        /* ratio = (current scaled) / feedback; fault if < 0x12 */
        word ratio = div16((word)((word)current << 3), R8(0x0241));
        if ((int)(ratio - 0x12) < 0) {
            R8(0x0240) &= (byte)~0x01;
            ok = 0;
        }
    }
    Output_Stop();                   /* stop the drive */
    return ok;
}

/* ======================================================================
 * Ramp_Limit  [0xB667]   slew-rate limiter
 * Moves a value toward a target by at most 'step' per call.  Parameter
 * block (on the stack in the original): current value, target, step and a
 * "still moving" flag pointer.  When step == 0, or the target is already
 * reached, it snaps to the target and clears the moving flag; otherwise it
 * adds/subtracts 'step' (clamped so it does not overshoot) and leaves the
 * flag set.  Used to filter the supply voltage and to ramp the heater /
 * motor outputs.  (Exact signed arithmetic: reference/application.asm
 * 0xB667-0xB706.)
 * ====================================================================== */
byte Ramp_Limit(byte step, byte *flag, byte current, byte target)
{
    int delta;

    if (step == 0 || current == target) {
        if (flag) *flag = 0;            /* reached / no limiting */
        return target;
    }
    delta = (int)target - (int)current;
    if (delta > 0) {
        current = (byte)(current + ((delta <= step) ? delta : step));
    } else {
        delta = -delta;
        current = (byte)(current - ((delta <= step) ? delta : step));
    }
    if (flag) *flag = (byte)(current != target);
    return current;
}
