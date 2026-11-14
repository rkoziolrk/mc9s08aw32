/*
 * main.c - Application entry point, CPU/clock initialisation, the 10 ms
 *          time base and the cooperative task scheduler.
 *
 * Decompiled from the application image (0x86E0-0x8A28) of the
 * MC9S08AW32 firmware.  The original was built with CodeWarrior for HC08
 * (the run-time support routines, startup code and calling convention are
 * the CodeWarrior ones).  Original addresses are given in brackets.
 *
 * Time base
 * ---------
 * TPM2 channel 0 runs as a free running output compare that re-arms itself
 * every 9998 bus clocks (~1 ms at the 10 MHz bus clock).  Every second
 * compare interrupt sets g_tickFlag; main() waits for that flag and then
 * runs Scheduler_Run().  g_tickCount counts these ticks 0..99 and the
 * scheduler derives the 2/5/10/25-tick tasks from it.
 */
#include "app.h"

/* ---------------------------------------------------------------------- */
/* Scheduler / time base variables                                        */
/* ---------------------------------------------------------------------- */
volatile byte g_tickCount;        /* [0x01A0] 0..99, incremented by the TPM2CH0 ISR every 2nd compare */
volatile byte g_tickFlag;         /* [0x01A1] set to 1 by the ISR, cleared by main()                   */
byte          g_slot10;           /* [0x01A3] 1..10 sub-slot counter of the 10-tick task               */
byte          g_tickSnapshot;     /* [0x01A4] copy of g_tickCount used by the scheduler               */
word          g_tpm2NextCompare;  /* [0x01A7] next TPM2CH0 compare value                              */

/* Initialised data (copied from ROM 0xC185 at reset, RAM 0x0100..0x0113) */
byte g_sleepState     = 0;        /* [0x0100] bit0: sleep requested, bit1: ready to enter STOP        */
byte g_sleepPrepared  = 0;        /* [0x0101] the "go to sleep" preparation was already done          */
byte g_nvmEventFlags  = 0;        /* [0x0102] bit0: an NVM (config) save cycle has finished           */
byte g_nvmTaskDivider = 0;        /* [0x0103] divides the 10-tick slot by 6 for the NVM state machine */
byte g_isrDivider     = 0;        /* [0x0104] TPM2CH0 interrupt divider (/2)                          */
/* (0x0105..0x0113 are defined in the modules that use them)                                       */

/* ---------------------------------------------------------------------- */
/* Local prototypes                                                       */
/* ---------------------------------------------------------------------- */
static void Scheduler_Run(void);
static void Task_2Ticks(void);
static void Task_5Ticks(void);
static void Task_10Ticks(void);
static void Task_25Ticks(void);
static void Sleep_Enter(void);
static void Clock_Init(void);
static void SysOpt_Init(void);
static void NvmTask_Run(void);
static void TickCount_Adjust(word ticks);

/* ======================================================================
 * main  [0x874D]
 * Initialises all peripherals and modules, then runs the scheduler once
 * per time-base tick, forever.
 * ====================================================================== */
void main(void)
{
    App_InitAll();                      /* [0x876D] */
    g_tickCount    = 0;
    g_tickSnapshot = 0;
    g_slot10       = 0;
    g_tickFlag     = 0;
    SRTISC         = 0x00;              /* real-time interrupt off */

    for (;;) {
        while (g_tickFlag != 1) {
            /* wait for the next tick */
        }
        Scheduler_Run();                /* [0x8835] */
        g_tickFlag = 0;
    }
}

/* ======================================================================
 * App_InitAll  [0x876D]
 * Complete (re-)initialisation of the hardware and of all software
 * modules.  Called at power-up and again after waking up from STOP.
 * ====================================================================== */
void App_InitAll(void)
{
    EnterCritical();                    /* [0xB7B8] */
    Clock_Init();                       /* [0x8967] ICG: FEI, bus ~10 MHz        */
    SysOpt_Init();                      /* [0x8986] COP enabled, STOP enabled    */
    COP_Feed();                         /* [0x89D0] */
    Ports_Init();                       /* [0xB415] GPIO directions / pull-ups   */
    Nvm_Init();                         /* [0x8A85] load configuration from flash*/
    Adc_Init();                         /* [0xBEC2] */
    Inputs_Init();                      /* [0xB84D] */
    Tpm2_Init();                        /* [0x8A60] time base + LIN capture      */
    COP_Feed();                         /* [0x89D0] */
    ResetLog_Init();                     /* [0xBC54] */
    Tpm1_Init();                        /* [0x8A29] PWM outputs                  */
    BacklightOut_Init();                       /* [0xA99E] */
    Backlight_Init();                        /* [0xA12E] */
    Diag_Init();                        /* [0xB5A3] */
    LinSignals_Init();                  /* [0xAC81] */
    Buttons_Init();                       /* [0xAA10] */
    Sensor_Init();                      /* [0xA0E6] */
    Supply_Init();                      /* [0xB932] */

    if ((g_featureFlags & FEAT_SCROLL) && (g_testMode == 0)) {
        Scan_Init();                /* [0xA6F9] */
        Backlight_Start();                   /* [0xA1E6] */
    }
    if ((g_featureFlags & FEAT_HEATER) && (g_testMode == 0)) {
        Heating_Init();                  /* [0xB7D9] */
    }
    LinApp_Reset();                     /* [0x8E10] */
    LinSignals_Refresh();               /* [0xACB7] */
    ExitCritical();                     /* [0xB7C5] */
}

/* ======================================================================
 * Isr_Default  [0x87D0]
 * Handler installed for every unused interrupt vector: it simply
 * restarts the application (calls the reset entry point).
 * ====================================================================== */
INTERRUPT void Isr_Default(void)
{
    _Startup();
}

/* ======================================================================
 * Sleep_Process  [0x87DC]
 * Handles the LIN "go to sleep" request.  When sleep is requested the
 * configuration is saved to flash first; when the save has completed
 * (g_sleepState bit1, set by Nvm_SetEvent) the MCU enters STOP.
 * ====================================================================== */
static void Sleep_Process(void)
{
    if (g_sleepState & 0x02) {
        Sleep_Enter();                  /* [0x8954] */
    }
    if ((g_linAppFlags & LINAPP_SLEEP_REQ) && (g_sleepPrepared == 0)) {
        g_sleepState = 0x01;
        Nvm_RequestSave();              /* [0x8B39] */
        Status_SetCode(0);                /* [0xAA0C] */
        g_sleepPrepared = 1;
    }
}

/* ======================================================================
 * Nvm_SetEvent  [0x8805]
 * Records an NVM event (bit mask in 'mask').  When exactly bit0 is set
 * (save cycle finished) the device is allowed to enter STOP mode.
 * ====================================================================== */
void Nvm_SetEvent(byte mask)
{
    g_nvmEventFlags |= mask;
    if (g_nvmEventFlags == 1) {
        g_sleepState |= 0x02;
    } else {
        g_sleepState &= (byte)~0x02;
    }
}

/* ======================================================================
 * TickCount_Adjust  [0x8819]
 * Advances the scheduler tick counter by 'ticks' (modulo 100).  Used to
 * compensate the time the CPU was blocked by a flash erase/program.
 * ====================================================================== */
static void TickCount_Adjust(word ticks)
{
    EnterCritical();
    g_tickCount = (byte)(g_tickCount + (byte)ticks);
    g_tickCount = (byte)(g_tickCount % 100);
    ExitCritical();
}

/* ======================================================================
 * Scheduler_Run  [0x8835]
 * Called once per tick.  Dispatches the periodic tasks:
 *   every 2 ticks  -> Task_2Ticks
 *   every 5 ticks  -> Task_5Ticks
 *   every 10 ticks -> Task_10Ticks
 *   every 25 ticks -> Task_25Ticks
 * ====================================================================== */
static void Scheduler_Run(void)
{
    g_tickSnapshot = g_tickCount;
    if ((g_tickSnapshot & 0x01) == 0) {
        Task_2Ticks();                  /* [0x888D] */
    }
    if (((int)g_tickSnapshot % 5) == 0) {
        Task_5Ticks();                  /* [0x8898] */
    }
    if (((int)g_tickSnapshot % 10) == 0) {
        Task_10Ticks();                 /* [0x88A1] */
    }
    if (((int)g_tickSnapshot % 25) == 0) {
        Task_25Ticks();                 /* [0x894E] */
    }
    if (g_tickSnapshot >= 100) {
        g_tickCount    = 0;
        g_tickSnapshot = 0;
    }
}

/* [0x888D] 2-tick task: supply voltage monitor + watchdog service */
static void Task_2Ticks(void)
{
    if (g_testMode == 0) {
        Supply_Task();                  /* [0xB9FD] */
    }
    COP_Feed();
}

/* [0x8898] 5-tick task: fault / input debouncing */
static void Task_5Ticks(void)
{
    if (g_testMode == 0) {
        Buttons_Scan();                   /* [0xAA36] */
    }
}

/* ======================================================================
 * Task_10Ticks  [0x88A1]
 * The 10-tick task is split into 10 sub slots (g_slot10 = 1..10), each
 * slot running a different group of jobs.
 * ====================================================================== */
static void Task_10Ticks(void)
{
    g_slot10++;
    NvmTask_Run();                      /* [0x898D] */

    if ((g_featureFlags & FEAT_SCROLL) && (g_testMode == 0)) {
        Backlight_Task();                    /* [0xA256] */
    }

    switch (g_slot10) {
    case 1: case 3: case 7:
        LinApp_DecodeCommand();         /* [0x8E35] */
        break;

    case 2: case 4: case 6: case 8:
        BacklightOut_Task();                   /* [0xA9A9] */
        SelfTest_Task();                 /* [0xBCB1] */
        break;

    case 5:
        if ((g_featureFlags & FEAT_HEATER) && (g_testMode == 0)) {
            Heating_Task();              /* [0xB7E8] */
        }
        LinApp_DecodeCommand();
        if (g_testRequest == 1) {
            g_testRequest = 0;
        }
        break;

    case 9:
        LinApp_DecodeCommand();
        Diag_Task();                    /* [0xB4D7] */
        break;

    case 10:
        if ((g_featureFlags & FEAT_HEATER) && (g_testMode == 0)) {
            Heating_Task();
        }
        if ((g_featureFlags & FEAT_SCROLL) &&
            (g_supplyVoltage <  CFG_U_MAX_RUN()) &&
            (g_supplyVoltage >  CFG_U_MIN_RUN()) &&
            (g_testMode == 0)) {
            Scan_Task();            /* [0xA5B5] */
        }
        Backlight_SlowTask();                /* [0xA694] */
        SelfTest_Task();
        Sleep_Process();                /* [0x87DC] */
        LinApp_CountIdle();             /* [0x8EC7] */
        Diag_SlowTask();                /* [0xB5AA] */
        g_slot10 = 0;
        break;

    default:
        g_slot10 = 0;
        break;
    }
    NvmTask_Run();
}

/* [0x894E] 25-tick task: LIN bus supervision and the signal handler */
static void Task_25Ticks(void)
{
    LinApp_Supervise();                 /* [0x8E8B] */
    Signals_Task();                     /* [0xAE36] */
}

/* ======================================================================
 * Sleep_Enter  [0x8954]
 * Puts the MCU in STOP mode (LIN bus sleep).  Before stopping, SCI1 is
 * disabled and the I/O pins are switched to their low power state.  After
 * wake-up the whole application is initialised again.
 * ====================================================================== */
static void Sleep_Enter(void)
{
    DisableInterrupts();
    LinDrv_Disable();                   /* [0x8ED5] SCI1C2 = 0          */
    Ports_PrepareSleep();               /* [0xB529] */
    Ports_AllInputs();                  /* [0xB53F] */
    STOP();
    App_InitAll();
    g_sleepState = 0;
}

/* ======================================================================
 * Clock_Init  [0x8967]
 * ICG in FEI mode (internal reference, FLL engaged), MFD = x18, RFD = /1.
 * Waits for FLL lock and DCO stable and loads the trim from NVICGTRM.
 * ====================================================================== */
static void Clock_Init(void)
{
    ICGC1 = 0x2A;
    ICGC2 = 0x70;
    while ((ICGS1 & ICGS1_LOCK) == 0) { }
    while ((ICGS2 & ICGS2_DCOS) == 0) { }
    ICGTRM = NVICGTRM;
}

/* [0x8986] SOPT: COP enabled (long timeout), STOP mode enabled, BKGD pin enabled */
static void SysOpt_Init(void)
{
    SOPT = 0xEF;
    COP_Feed();
}

/* ======================================================================
 * NvmTask_Run  [0x898D]
 * Runs the flash save state machine every 6th call.  While it executes,
 * PTE7 is driven low.  The time spent in a flash operation (returned by
 * Nvm_Process) is added to the scheduler tick counter.
 * ====================================================================== */
static void NvmTask_Run(void)
{
    byte delay = 0;

    COP_Feed();
    if (++g_nvmTaskDivider >= 6) {
        Ports_NvmPinLow();              /* [0xB519] PTED &= ~0x80 */
        EnterCritical();
        delay = Nvm_Process();          /* [0x8BEA] */
        if (delay != 0) {
            COP_Feed();
            Ports_NvmPinHigh();         /* [0xB521] PTED |= 0x80 */
            g_nvmTaskDivider = (byte)(delay / 5);
            TickCount_Adjust((word)delay + 1);
        } else {
            g_nvmTaskDivider = 0;
        }
        ExitCritical();
    } else {
        Ports_NvmPinHigh();
    }
}

/* [0x89D0] Services the COP watchdog (0x55, 0xAA to SRS) */
void COP_Feed(void)
{
    SRS = 0x55;
    SRS = 0xAA;
}

/* ======================================================================
 * Isr_Tpm2Ch0  [0x89DA]  (TPM2 channel 0 output compare)
 * Re-arms the compare 9998 bus clocks later, sets the tick flag every
 * second interrupt (and advances g_tickCount + runs the LIN timeout
 * handler) and services the button/scroll scan on every interrupt.
 * ====================================================================== */
INTERRUPT void Isr_Tpm2Ch0(void)
{
    volatile byte dummy;

    dummy = TPM2C0SC;                   /* read status to arm flag clearing */
    g_tpm2NextCompare = TPM2C0V;
    TPM2C0SC &= 0x7F;                   /* clear CH0F */
    g_tpm2NextCompare += 9998u;
    TPM2C0V = g_tpm2NextCompare;

    g_isrDivider++;
    if ((byte)(g_isrDivider >> 1) == 1) {
        g_tickFlag   = 1;
        g_isrDivider = 0;
        LinTp_Timer();                  /* [0x9C31] */
        g_tickCount++;
    }
    Scan_Isr();                     /* [0xA719] */
    (void)dummy;
}

/* ======================================================================
 * Tpm1_Init  [0x8A29]
 * TPM1: bus clock, prescaler /2, overflow interrupt enabled,
 * modulo 0xC800.  Channel 1 is an edge aligned PWM (only when the
 * configuration selects the PWM output variant), channel 2 is prepared,
 * channels 0 and 3 are off.
 * ====================================================================== */
void Tpm1_Init(void)
{
    TPM1SC   = 0x49;
    TPM1MODH = 0xC8;
    TPM1MODL = 0x00;
    if (g_outputVariant == 1) {
        TPM1C1VH = 0x64;
        TPM1C1VL = 0x00;
        TPM1C1SC = 0x24;                /* edge aligned PWM, high-true */
    } else {
        TPM1C1SC = 0x00;
    }
    TPM1C2VH = 0xC8;
    TPM1C2VL = 0x00;
    TPM1C2SC = 0x00;
    TPM1C0SC = 0x00;
    TPM1C3SC = 0x00;
}

/* ======================================================================
 * Tpm2_Init  [0x8A60]
 * TPM2: bus clock /1, free running.  CH0 = output compare (time base,
 * interrupt enabled), CH1 = input capture used for LIN auto baud.
 * ====================================================================== */
void Tpm2_Init(void)
{
    g_tpm2NextCompare = 0x270E;
    TPM2SC   = 0x08;
    TPM2MODH = 0x00;
    TPM2MODL = 0x00;
    TPM2C0SC = 0x50;                    /* CH0IE | MS0A : output compare, software only */
    TPM2C1SC = 0x00;
    TPM2C0V  = g_tpm2NextCompare;
    TPM2C1VH = 0x00;
    TPM2C1VL = 0x00;
}
