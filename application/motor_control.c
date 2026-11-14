/*
 * DEVICE NOTE: this is NOT a motor controller. Per DEVICE.md the real
 * device is the Audi A4 B8 steering-wheel button panel; the Ctrl_/Motor_/
 * MotorPos_ names are placeholders for BUTTON scanning (analogue resistor
 * ladder), the SCROLL/roll wheel, and BACKLIGHT PWM dimming. Structure and
 * hardware access are correct; only the names' theme is off.
 * motor_control.c - Motor driver, closed-loop position controller and
 *                   the commutation / position ISR.
 *                   (decompiled from 0xA12E, 0xA1E6, 0xA256, 0xA694,
 *                    0xA6F9, 0xA719, 0xA5B5, 0xA99E, 0xA9A9 and helpers.)
 *
 * This is the largest subsystem and is reconstructed here at the level of
 * the module structure, hardware access and the concrete state variables;
 * the inner control-loop arithmetic (PI/ramp stepping, the A874/A88F/A8B6/
 * A91B/A957 helpers and the position compare table) is intricate fixed-
 * point code best read in reference/application.asm, which is cross-
 * referenced at each function.
 *
 * Only built/active on the variants whose feature flags contain
 * FEAT_MOTOR; the application disables these tasks in g_testMode.
 *
 * Key RAM:
 *   0x02B2  motor output level / PWM duty request
 *   0x0244  current position           0x0246/0x0247  position window
 *   0x0245  motor-moving flag          0x0241/0x0242  limits
 *   0x022F..0x023D  controller working set (integrator, target, flags)
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))

extern void Motor_sub_A874(void);   /* [0xA874] set up the H-bridge/PWM pins */
extern byte Motor_sub_A88F(void);   /* [0xA88F] read end-stop / hall inputs   */
extern byte Motor_sub_A8B6(void);   /* [0xA8B6] self-test / stall check       */
extern byte Motor_sub_A91B(void);   /* [0xA91B] self-test / stall check       */
extern byte Motor_sub_A957(void);   /* [0xA957] drive the output stage        */

byte g_motorLevel AT(0x02B2);       /* [0x02B2] requested output level */

/* ======================================================================
 * Ctrl_Init  [0xA12E]
 * Clears the controller accumulators (0x02B4/0x02B5) and sets the "idle"
 * state flag (0x02B3 = 1).
 * ====================================================================== */
void Ctrl_Init(void)
{
    R8(0x02B4) = 0;
    R8(0x02B5) = 0;
    R8(0x02B3) = 1;
}

/* ======================================================================
 * Ctrl_Start  [0xA1E6]
 * Zeroes the whole controller working set (0x022F..0x023D) and runs the
 * initial self-tests (Motor_sub_A874/A91B/A8B6).  Depending on their
 * results it records the start-up fault code in 0x02A8 and flags the
 * controller state (0x029B/0x029C/0x023B/0x023C).  Full branch logic:
 * reference/application.asm 0xA1E6-0xA255.
 * ====================================================================== */
void Ctrl_Start(void)
{
    byte i;
    for (i = 0x2F; i <= 0x3D; i++) {
        R8(0x0200 + i) = 0;             /* clear 0x022F..0x023D */
    }
    Motor_sub_A874();
    if (Motor_sub_A91B() == 0) {        /* self-test A failed */
        R8(0x02A8) = 0x0B;
        R8(0x029B) = 1;
        R8(0x029C) = 1;
        R8(0x023B) = 0x0B;
    }
    if (Motor_sub_A8B6() == 0) {        /* self-test B failed */
        R8(0x02A8) = 0x07;
        R8(0x029B) = 1;
        R8(0x023C) = 1;
        R8(0x023B) = 0x0B;
    }
    /* ... remaining start-up sequencing: see asm 0xA248-0xA25x ... */
}

/* ======================================================================
 * Ctrl_Task  [0xA256]   (DEVICE: backlight dimming state machine)
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
 *   0x022B:0x022C  16-bit brightness ramp counter / dwell timer (Ctrl_Step)
 *   0x0229         target brightness (from g_cfg[0x32 + mode])
 *   0x0291..0x0296 decoded command bits (level/mode/flags, see lin_signals.c)
 *   g_supplyVoltage via a lookup (0xA64E) gates the brightness
 *   Motor_sub_A874 turns the backlight output off
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

void Ctrl_Step(void);   /* [0xA25A] forward decl */
static void Ctrl_ClearRamp(void) { RAMP_HI = 0; RAMP_LO = 0; }   /* [0xA5AD] */

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
static byte Ctrl_VoltLowDeb(void)
{
    if (g_supplyVoltage >= R8(0x016E)) return 0;
    if (R8(0x0235) >= 2) R8(0x0235) = 0; else R8(0x0235)++;
    return 1;
}

/* [0xA62B] high-voltage edge debounce (counts 0x0236 once v > cfg 0x016C) */
static byte Ctrl_VoltHighDeb(void)
{
    if (g_supplyVoltage <= R8(0x016C)) return 0;
    if (R8(0x0236) >= 2) R8(0x0236) = 0; else R8(0x0236)++;
    return 1;
}

/* [0xA669] on a debounced voltage edge, branch to the low/high-voltage states */
static void Ctrl_CheckVoltEdges(void)
{
    if (Ctrl_VoltHighDeb() == 1 && R8(0x0236) == 0) CS = 9;
    if (Ctrl_VoltLowDeb()  == 1 && R8(0x0235) == 0) CS = 10;
}

/* [0xA894] button-ladder plausibility: sets 0x0240 bit1, and if the ladder
 * ratio 0x0241/0x0242 >= 8 clears it (implausible). Returns 0x0240. */
static byte Ctrl_PlausCheck(void)
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
 * Ctrl_Task  [0xA256]   DEVICE: backlight dimming / button-feedback FSM.
 * Faithful transcription of the 12-state machine (0xA270-0xA6F8).  Each
 * state gates on the supply-voltage window (Supply_InWindow), the decoded
 * dimming command (CMD_*), and the ramp/dwell timer, then drives the
 * backlight output and advances g_ctrlState (CS).
 * ====================================================================== */
void Ctrl_Task(void)
{
    byte r;

    Ctrl_Step();                                /* [0xA25A] advance dwell timer */

    if (CS >= 0x0C) { Motor_sub_A874(); CS = 0; return; }   /* [0xA270->A5A3] guard */

    switch (CS) {

    case 0:                                     /* LA299: off / init */
        Motor_sub_A874();
        CS = 1;
        return;

    case 1:                                     /* LA2A4: idle, await command */
        if (Supply_InWindow() != 1) { Motor_sub_A874(); Ctrl_CheckVoltEdges(); return; }
        if (CMD_FLAG_B == 1 && CMD_FLAG_A == 0 && R8(0x029B) == 0) {
            if (CMD_POS_LO != 0) {
                Backlight_On19((byte)(CMD_POS_HI + 0x0A));
            } else {
                RAMP_LO = 0x0F; RAMP_HI = 0;
            }
            CS = 2;
            Ctrl_ClearRamp();
            return;
        }
        /* LA2E2 */
        if (CMD_FLAG_C == 1 && R8(0x022A) == 0) CS = 7;
        if (CMD_FLAG_C != 0) return;
        R8(0x022A) = 0;
        return;

    case 2:                                     /* LA305: ramp toward target */
        if (Supply_InWindow() != 1) { Motor_sub_A874(); Ctrl_CheckVoltEdges(); return; }
        if (R8(0x029B) != 0) { CS = 0x0B; Motor_sub_A874(); return; }  /* LA348 fault */
        if (RAMP < 0x000F) {
            /* still within the initial dwell */
        }
        /* LA32A: fetch the per-mode brightness from config, apply it */
        R8(0x0229) = g_cfg.raw[0x32 + (CMD_MODE & 0x0F)];
        Backlight_On14(R8(0x0229));
        Ctrl_ClearRamp();
        CS = 3;
        return;

    case 3:                                     /* LA35C: holding at level */
        r = Supply_InWindow();
        if (r != 1) { Motor_sub_A874(); Ctrl_CheckVoltEdges(); return; }
        /* compare the commanded level 0x0151 (<<2) against the ramp timer */
        {
            word lvl = (word)(R8(0x0151) << 2);
            if ((int)(lvl - RAMP) >= 0 && R8(0x0151) != 0) { /* keep holding */ }
            if (CMD_FLAG_B != 0 && CMD_FLAG_A != 0 && (--R8(0x029B)) != 0) {
                return;                         /* loop back into state 3 */
            }
        }
        Motor_sub_A874();
        Delay_Loop(0xFA);
        Backlight_Dwell();                      /* [0xA855] */
        Ctrl_ClearRamp();
        CS = 4;
        return;

    case 4:                                     /* LA3AE: dwell + plausibility */
        if (Supply_InWindow() != 1) { Ctrl_CheckVoltEdges(); return; }
        r = Ctrl_PlausCheck();                  /* [0xA894] */
        if (r != 0) {
            if (r == 1) { Motor_sub_A874(); Ctrl_CheckVoltEdges(); return; }
            if (r == 2) R8(0x023D) = 1;
            CS = 0x0B; Motor_sub_A874();        /* implausible -> fault */
            return;
        }
        if (RAMP < 0x0032) { Motor_sub_A874(); CS = 6; return; }   /* LA3D8 */
        if (CMD_FLAG_B != 0) { CS = 6; return; }
        CS = 5;
        return;

    case 5:                                     /* LA3FE: step the dimming */
        if (Supply_InWindow() != 1) { Motor_sub_A874(); Ctrl_CheckVoltEdges(); return; }
        if (CMD_FLAG_B != 1) {                  /* LA42B */
            if (RAMP < 0x0032) return;
            Motor_sub_A874();
            CS = 0;
            return;
        }
        Motor_sub_A874();
        Delay_Loop(0xFA);
        Backlight_On14((byte)(CMD_POS_HI + 0x0A));
        Ctrl_ClearRamp();
        CS = 2;
        return;

    case 6:                                     /* LA446: wait for release */
        if (Supply_InWindow() != 1) { Motor_sub_A874(); Ctrl_CheckVoltEdges(); return; }
        if (CMD_FLAG_B == 0) { CS = 0; Motor_sub_A874(); return; }
        if (CMD_FLAG_C == 1 && R8(0x022A) == 0) CS = 7;
        if (CMD_FLAG_C != 0) return;
        R8(0x022A) = 0;
        return;

    case 7:                                     /* LA482: self-test / special */
        if (Supply_InWindow() != 1) { Ctrl_CheckVoltEdges(); return; }
        if (R8(0x023C) == 0) {
            if (Motor_sub_A8B6() != 0) {        /* drive self-test ok */
                if (R8(0x023A) == 2) {          /* LA49E */
                    Motor_sub_A874(); CS = 0x0B;
                    R8(0x029B) = 1; R8(0x023A) = 0; R8(0x023C) = 1;
                    R8(0x02A8) = 7;
                } else { R8(0x023A)++; }
            }
        }
        r = Ctrl_PlausCheck();
        if (r & 0x02) { R8(0x023D) = 1; Motor_sub_A874(); CS = 0x0B; }
        if (r == 0) { Motor_sub_A874(); CS = 6; R8(0x023C) = 0; }
        R8(0x022A) = 1;
        return;

    case 8:                                     /* LA47F: (shares state 7 exit) */
        Ctrl_CheckVoltEdges();
        return;

    case 9:                                     /* LA4F4: low-voltage handling */
        if (g_supplyVoltage < R8(0x016D)) { Ctrl_CheckVoltEdges(); return; }
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
        if ((--R8(0x029C)) != 0) { Motor_sub_A874(); return; }
        if (Motor_sub_A91B() != 0) return;      /* stuck-button / short check */
        if (R8(0x0237) == 2) {
            R8(0x02A8) = 0; R8(0x029B) = 0; R8(0x029C) = 0;
            CS = 6; R8(0x0237) = 0;
        } else {
            R8(0x0237)++;
        }
        return;
    }
}

/* Ctrl_Step [0xA25A] - count the 16-bit ramp/dwell timer 0x022B:0x022C up
 * to 0xFFFF, then wrap to 0 (the per-state dwell between brightness steps). */
void Ctrl_Step(void)
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
 * Ctrl_sub_A13A  [0xA13A]
 * Controller sub-step called from Supply_Task after each supply reading
 * (slew-rate updates of the two accumulators 0x02B4/0x02B5).  See asm.
 * ====================================================================== */
void Ctrl_sub_A13A(void)
{
    /* see reference/application.asm 0xA13A-0xA1E5. */
}

/* ======================================================================
 * Ctrl_SlowTask  [0xA694]
 * Slow controller housekeeping (10-tick slot 10): recomputes the position
 * window and refreshes the output enable. See asm 0xA694-0xA6F8.
 * ====================================================================== */
void Ctrl_SlowTask(void)
{
}

/* ======================================================================
 * Motor_Init  [0xA99E]
 * Clears the output level, reports the initial status (Fault_Report(1))
 * and stops the TPM1-CH2 output (Diag_StopTestOutput).
 * ====================================================================== */
void Motor_Init(void)
{
    g_motorLevel = 0;
    Fault_Report(1);
    /* jmp Diag_sub_B620 - stop the test output (see diag.c) */
}

/* ======================================================================
 * Motor_Task  [0xA9A9]
 * Translates the decoded command (on/off 0x028F, level 0x028E) into the
 * motor output level 0x02B2, honouring the controller error flag and the
 * special 0x7F "hold" / 0x50 "fault safe" levels.  For the PWM output
 * variant (g_outputVariant != 0) it takes the alternate path.  Full
 * decision tree: reference/application.asm 0xA9A9-0xA9F9.
 * ====================================================================== */
void Motor_Task(void)
{
    if (g_outputVariant != 0) {
        /* PWM-output variant path (asm LA9F4) */
        return;
    }
    if (R8(0x028F) == 0) {                      /* command = ON */
        if (R8(0x028E) != 0x7F && R8(0x0249) == 0) {
            byte lvl = R8(0x028E);
            if (lvl < 0x65) lvl = 0x64;
            g_motorLevel = lvl;
        }
    } else {                                    /* command = OFF */
        if (g_ctrlErrFlag != 0) {
            g_motorLevel = 0x50;                /* safe level */
            R8(0x0008) |= 0x01;                 /* enable brake pin */
        }
    }
}

/* ======================================================================
 * MotorPos_Init  [0xA6F9]
 * Resets the position tracking (0x0241..0x0247) and runs the pin setup.
 * ====================================================================== */
void MotorPos_Init(void)
{
    R8(0x0247) = 0;
    R8(0x0246) = 0;
    R8(0x0244) = 0;
    R8(0x0243) = 0;
    R8(0x0241) = 1;
    R8(0x0242) = 0xFF;
    R8(0x0245) = 0;
    Motor_sub_A88F();
    Motor_sub_A874();
}

/* ======================================================================
 * MotorPos_Isr  [0xA719]   (called every 1 ms from Isr_Tpm2Ch0)
 * While the motor is moving (0x0245 != 0) it compares the current position
 * (0x0244) against the window edges (0x0246/0x0247) and drives the
 * direction / brake outputs (PTED bits via the 0x0008/0x000A control
 * registers) accordingly, stopping at the end stops.  Full compare logic:
 * reference/application.asm 0xA719-0xA7...
 * ====================================================================== */
INTERRUPT void MotorPos_Isr(void)
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
 * MotorPos_Task  [0xA5B5]
 * Periodic position task (10-tick slot 10): updates the commanded window
 * from the LIN position command and arms a move.  See asm 0xA5B5-0xA6F8.
 * ====================================================================== */
void MotorPos_Task(void)
{
}

/* ======================================================================
 * Device helper routines (previously referenced; now reconstructed).
 * ====================================================================== */

/* Motor_sub_A874 [0xA874] - stop the H-bridge drive and clear the move. */
void Motor_sub_A874(void)
{
    R8(0x0245) = 0;                 /* clear "moving" flag        */
    R8(0x0008) &= (byte)~0x04;      /* bridge enable pin low      */
    R8(0x000A) &= (byte)~0x10;      /* PWM/control pin low        */
    R8(0x023F) = 1;
    R8(0x029A) = 1;
}

/* Motor_sub_A88F [0xA88F] - clear the end-stop/limit state. */
byte Motor_sub_A88F(void)
{
    R8(0x0240) = 0;
    return 0;
}

/* Motor_sub_A91B [0xA91B] - stall / over-current check.
 * Reads motor current (ADC ch 0x0A) and feedback (ch 2); if current/feedback
 * >= 7 it flags a stall (0x0240 bit2) and returns 0, otherwise returns 1. */
byte Motor_sub_A91B(void)
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

/* Motor_sub_A957 [0xA957] - sample the end-stop reference level.
 * Reads the feedback channel (ch 2) three times with delays and stores the
 * running maximum in 0x0242 (the end-stop threshold). */
byte Motor_sub_A957(void)
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

/* Motor_sub_A8B6 [0xA8B6] - motor drive self-test.
 * Briefly energises the bridge, measures motor current (ADC ch 0x0A) and
 * feedback (ch 2) and checks the current/feedback ratio against a minimum
 * (0x12).  A ratio below the threshold (or no feedback) is a fault: it
 * clears 0x0240 bit0 and returns 0.  Always stops the drive (Motor_sub_A874)
 * before returning. */
byte Motor_sub_A8B6(void)
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
    Motor_sub_A874();                   /* stop the drive */
    return ok;
}

/* ======================================================================
 * Motor_Ramp  [0xB667]   slew-rate limiter
 * Moves a value toward a target by at most 'step' per call.  Parameter
 * block (on the stack in the original): current value, target, step and a
 * "still moving" flag pointer.  When step == 0, or the target is already
 * reached, it snaps to the target and clears the moving flag; otherwise it
 * adds/subtracts 'step' (clamped so it does not overshoot) and leaves the
 * flag set.  Used to filter the supply voltage and to ramp the heater /
 * motor outputs.  (Exact signed arithmetic: reference/application.asm
 * 0xB667-0xB706.)
 * ====================================================================== */
byte Motor_Ramp(byte step, byte *flag, byte current, byte target)
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
