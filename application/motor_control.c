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
void Ctrl_Task(void)
{
    Ctrl_Step();                    /* [0xA25A] advance the ramp/dwell timer */
    /* then dispatch g_ctrlState (0x023B) through the 12-entry switch table;
     * each state ramps brightness toward 0x0229 and advances the sequence.
     * See reference/application.asm 0xA270-0xA6F8. */
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
