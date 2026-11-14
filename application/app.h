/*
 * app.h - Shared declarations for the MC9S08AW32 LIN-slave application.
 *
 * Collects the global RAM variables, the configuration image layout and
 * the public prototypes of every reconstructed module.  Addresses in
 * brackets are the absolute RAM/flash addresses used by the firmware;
 * variables that the hand-written assembly addresses by fixed address
 * are pinned there with AT().
 */
#ifndef APP_H
#define APP_H

#include "mc9s08aw32.h"

/* Pin a variable to an absolute address (needed for the variables the
 * RAM-resident flash routines reach with zero-page / extended addressing). */
#if defined(AW32_HOSTCHECK)
#  define AT(addr)
#elif defined(__SDCC)
#  define AT(addr) __at(addr)
#else
#  define AT(addr) @addr          /* CodeWarrior */
#endif

/* ---------------------------------------------------------------------- */
/* Feature flags (g_featureFlags, set from the coding ADC, see adc.c)      */
/* ---------------------------------------------------------------------- */
#define FEAT_BIT0        0x01
#define FEAT_HEATER      0x02     /* checked in the 10-tick task          */
#define FEAT_MOTOR       0x04     /* checked in init and the 10-tick task */
#define FEAT_BIT3        0x08

/* LIN application flag byte g_linAppFlags [0x02AE] */
#define LINAPP_SLEEP_REQ 0x01     /* go-to-sleep requested                */
#define LINAPP_BIT1      0x02
#define LINAPP_BUS_ACT   0x04     /* LIN bus activity / frame in progress */

/* ---------------------------------------------------------------------- */
/* Configuration image (128 bytes, RAM copy at 0x0120, stored in flash)   */
/* ---------------------------------------------------------------------- */
typedef struct {
    byte raw[128];
    /* Known fields (offsets inside raw[]):
     *   [0x00] write counter low        [0x7F] write counter high
     *   [0x42] param @0x0162            [0x43] param @0x0163
     *   [0x48] supply cal @0x0168       [0x49] supply cal @0x0169
     *   [0x4B] variant nibble @0x016B
     *   [0x4C..0x4D] uMaxRun (0x016C)   [0x4E..0x4F] uMinRun (0x016E)
     *   [0x5E..0x5F] check word (chosen so Nvm_Checksum() == 0xCAFE)
     */
} Config;

#define CFG_U_MAX_RUN()  ((word)((g_cfg.raw[0x4C] << 8) | g_cfg.raw[0x4D]))
#define CFG_U_MIN_RUN()  ((word)((g_cfg.raw[0x4E] << 8) | g_cfg.raw[0x4F]))

/* ---------------------------------------------------------------------- */
/* Global variables (defined in the various .c files)                      */
/* ---------------------------------------------------------------------- */
/* scheduler / time base (main.c) */
extern volatile byte g_tickCount;
extern volatile byte g_tickFlag;
extern byte          g_slot10;
extern byte          g_tickSnapshot;
extern word          g_tpm2NextCompare;
extern byte          g_sleepState, g_sleepPrepared, g_nvmEventFlags;
extern byte          g_nvmTaskDivider, g_isrDivider;
extern byte          g_criticalNesting;   /* [0x0108] */

/* nvm.c */
extern Config  g_cfg;
extern byte    g_nvmBank, g_nvmState;
extern byte    g_diagState;           /* [0x02A2] */
extern word    g_nvmCounterA, g_nvmCounterB;
extern byte   *g_nvmPage;

/* adc.c - variant detection results */
extern byte g_codingByte;      /* [0x0298] strap-coded byte                */
extern byte g_featureFlags;    /* [0x0299] enabled features (FEAT_*)       */
extern byte g_variantCode;     /* [0x02EC] hardware variant number         */
extern byte g_variantSub;      /* [0x02EB] variant sub-code                */
extern byte g_testMode;        /* [0x02EA] 1 = invalid/test coding         */
extern byte g_cfgDefaults;     /* [0x029D] 1 = no valid stored config      */

/* lin.c - LIN protocol state (zero page) */
extern volatile byte g_linCrit;        /* [0x00B0] LIN critical nesting    */
extern byte g_linTpState;              /* [0x00B1] transport timer/state   */
extern byte g_linRxState;              /* [0x00B7] byte engine state        */
extern byte g_linFrameState;           /* [0x00B8] frame state (0=idle,2=hdr,3=resp) */
extern byte g_linDiagState;            /* [0x00BC]                          */
extern byte g_linDiagActive;           /* [0x00BD]                          */
extern byte g_linRespErr;              /* [0x00BE] response error bits      */

/* lin.c - LIN protocol state (page 1) */
extern word g_baudPeriod;              /* [0x01B8] measured SYNC period     */
extern word g_baudCap;                 /* [0x01BA] last capture value       */
extern byte g_baudState;               /* [0x01BC] auto-baud state           */
extern byte g_linProductId;            /* [0x01BD]                          */
extern byte g_linVariant;              /* [0x01BE]                          */
extern byte g_linAppFlags;             /* [0x02AE]                          */

/* misc application state */
extern byte g_outputVariant;           /* [0x0275] selects PWM output style */
extern byte g_supplyVoltage;           /* [0x02B6] scaled supply voltage    */
extern byte g_testRequest;             /* [0x02B0]                          */
extern byte g_nvmSaveRequest;          /* [0x02B9] a config save is pending */

/* ---------------------------------------------------------------------- */
/* Prototypes                                                              */
/* ---------------------------------------------------------------------- */
/* startup (crt0 provided by the toolchain) */
void _Startup(void);

/* main.c */
void main(void);
void App_InitAll(void);
void COP_Feed(void);
void Nvm_SetEvent(byte mask);
void Tpm1_Init(void);
void Tpm2_Init(void);
INTERRUPT void Isr_Default(void);
INTERRUPT void Isr_Tpm2Ch0(void);

/* nvm.c */
void Nvm_Init(void);
void Nvm_RequestSave(void);
byte Nvm_Process(void);
void Nvm_Load(void);
byte Nvm_Verify(void);
word Nvm_Checksum(const word *p, word count);

/* adc.c */
byte Adc_Read(byte channel);
void Adc_Init(void);
void Adc_DetectVariant(void);
void Variant_ReadStraps(void);

/* lin.c */
void Sci_Init(void);
void Sci_SendByte(byte data);
void Lin_Init(void);
void Lin_Supervise(void);
INTERRUPT void Isr_Sci1(void);
INTERRUPT void Isr_Tpm2Ch1_AutoBaud(void);
void LinTp_Timer(void);

/* ports.c */
void Ports_Init(void);
void Ports_PrepareSleep(void);
void Ports_AllInputs(void);
void Ports_NvmPinLow(void);
void Ports_NvmPinHigh(void);

/* critical sections (ports.c / util) */
void EnterCritical(void);
void ExitCritical(void);
byte Delay_Loop(word count);

/* The remaining modules (control, motor, outputs, supply, fault, diag,
 * sensor, heater, signals, LIN transport & signal layer) are documented
 * in reference/function_index.md and reference/application.asm.  Their
 * prototypes are declared where reconstructed. */
void Ctrl_Init(void);  void Ctrl_Start(void);  void Ctrl_Task(void);  void Ctrl_SlowTask(void);
void Motor_Init(void); void Motor_Task(void);  void MotorPos_Init(void); void MotorPos_Task(void);
INTERRUPT void MotorPos_Isr(void);
void Fault_Init(void); void Fault_Task(void);  void Fault_Report(byte code);
void Outputs_Init(void); void Outputs_Task(void);
void Inputs_Init(void); void Supply_Init(void); void Supply_Task(void);
void Heater_Init(void); void Heater_Task(void);
void Diag_Init(void);  void Diag_Task(void);   void Diag_SlowTask(void);
void Sensor_Init(void); void Signals_Task(void);
void LinSignals_Init(void); void LinSignals_Refresh(void);
void LinApp_Reset(void); void LinApp_DecodeCommand(void);
void LinApp_Supervise(void); void LinApp_CountIdle(void);
void LinDrv_Disable(void);

#endif /* APP_H */
