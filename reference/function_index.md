# Function index

All recovered routines, by address. Names are the reverse-engineering
labels used throughout the C sources and the annotated `.asm` listings.

## Bootloader (0xF400-0xFE73)

| Addr | Name | Purpose |
|------|------|---------|
| 0xF400 | `Boot_Reset` | Bootloader reset/vector entry; checks reset source and jumps to the application at 0x86E0 when valid |
| 0xF485 | `Boot_Stop` | (see disassembly) |
| 0xF489 | `Boot_sub_F489` | (see disassembly) |
| 0xF53F | `Boot_sub_F53F` | (see disassembly) |
| 0xF5EE | `Boot_sub_F5EE` | (see disassembly) |
| 0xF626 | `Boot_Crc` | CRC/checksum over the downloaded image |
| 0xF677 | `Boot_sub_F677` | (see disassembly) |
| 0xF6B1 | `Boot_Main` | Bootloader main loop: LIN/SCI firmware-download protocol |
| 0xF73B | `Boot_sub_F73B` | (see disassembly) |
| 0xF759 | `Boot_FlashProgram` | Program bytes into application flash (runs from RAM) |
| 0xF77E | `Boot_sub_F77E` | (see disassembly) |
| 0xF7E4 | `Boot_sub_F7E4` | (see disassembly) |
| 0xF832 | `Boot_sub_F832` | (see disassembly) |
| 0xF8BD | `Boot_sub_F8BD` | (see disassembly) |
| 0xF948 | `Boot_sub_F948` | (see disassembly) |
| 0xF94C | `Boot_sub_F94C` | (see disassembly) |
| 0xF9C9 | `Boot_sub_F9C9` | (see disassembly) |
| 0xFA5B | `Boot_sub_FA5B` | (see disassembly) |
| 0xFAB4 | `Boot_sub_FAB4` | (see disassembly) |
| 0xFABE | `Boot_sub_FABE` | (see disassembly) |
| 0xFBAD | `Boot_FlashErase` | Erase an application flash page (runs from RAM) |
| 0xFBCF | `Boot_SciInit` | Initialise SCI1 for the bootloader download link |
| 0xFC10 | `Boot_SciGetc` | Blocking SCI1 receive |
| 0xFC56 | `Boot_SciPoll` | Non-blocking SCI1 receive poll |
| 0xFC67 | `Boot_SciPutc` | Blocking SCI1 transmit |
| 0xFCC4 | `Boot_SciPutHex` | Send a byte as ASCII hex |
| 0xFD06 | `Boot_sub_FD06` | (see disassembly) |
| 0xFD33 | `Boot_CopFeed` | Service the COP watchdog |
| 0xFD57 | `Boot_sub_FD57` | (see disassembly) |
| 0xFD76 | `Boot_Delay` | Busy-wait delay |
| 0xFDA9 | `Boot_sub_FDA9` | (see disassembly) |
| 0xFDE8 | `Boot_sub_FDE8` | (see disassembly) |
| 0xFDFE | `Boot_sub_FDFE` | (see disassembly) |

## Application (0x86E0-0xC24F)

| Addr | Name | Purpose |
|------|------|---------|
| 0x8620 | `Flash_BurstProgram` | Burst-program the config page (runs from RAM) |
| 0x8684 | `Flash_ErasePage` | Erase a config flash page (runs from RAM) |
| 0x86E0 | `App_Startup` | Application C startup: copy .data from ROM, zero .bss, call main() |
| 0x874D | `main` | Application entry: init everything then run the scheduler forever |
| 0x876D | `App_InitAll` | Full (re)initialisation of hardware and all software modules |
| 0x87D0 | `Isr_Default` | Default interrupt handler (restarts the application) |
| 0x87DC | `Sleep_Process` | Handle the LIN go-to-sleep request and enter STOP |
| 0x8805 | `Nvm_SetEvent` | Record an NVM event; allow STOP when a save has finished |
| 0x8819 | `TickCount_Adjust` | Advance the scheduler tick counter after a blocking flash op |
| 0x8835 | `Scheduler_Run` | Cooperative scheduler, dispatches the 2/5/10/25-tick tasks |
| 0x888D | `Task_2Ticks` | 2-tick task: supply monitor + watchdog |
| 0x8898 | `Task_5Ticks` | 5-tick task: fault handling |
| 0x88A1 | `Task_10Ticks` | 10-tick task (10 sub-slots): LIN decode, scroll/backlight, outputs, diag, sleep |
| 0x894E | `Task_25Ticks` | 25-tick task: LIN supervision + signal handling |
| 0x8954 | `Sleep_Enter` | Enter STOP low-power mode and re-init after wake |
| 0x895F | `App_InitAll_tail` | (see disassembly) |
| 0x8967 | `Clock_Init` | ICG init: FEI mode, bus ~10 MHz, load NV trim |
| 0x8986 | `SysOpt_Init` | SOPT: enable COP + STOP |
| 0x898D | `NvmTask_Run` | Run the flash save state machine every 6th tick |
| 0x89D0 | `COP_Feed` | Service the COP watchdog (0x55,0xAA to SRS) |
| 0x89DA | `Isr_Tpm2Ch0` | TPM2 CH0 output-compare ISR: 1 ms time base + button/scroll scan |
| 0x8A29 | `Tpm1_Init` | TPM1 init: PWM outputs |
| 0x8A60 | `Tpm2_Init` | TPM2 init: time base (CH0) + LIN auto-baud capture (CH1) |
| 0x8A85 | `Nvm_Init` | Select newest valid flash config bank and load it |
| 0x8B39 | `Nvm_RequestSave` | Start a save cycle of the configuration image |
| 0x8BEA | `Nvm_Process` | Flash config save state machine (erase/program/verify) |
| 0x8CBC | `Nvm_Load` | Copy flash config page into RAM image |
| 0x8CF3 | `Nvm_Verify` | Compare RAM image with flash page |
| 0x8D2A | `Nvm_Checksum` | XOR checksum over 16-bit words of the config image |
| 0x8D68 | `LinApp_ResetA` | (see disassembly) |
| 0x8D83 | `LinApp_ResetB` | (see disassembly) |
| 0x8D95 | `LinApp_sub_8D95` | (see disassembly) |
| 0x8D9D | `LinApp_sub_8D9D` | (see disassembly) |
| 0x8DA5 | `Clock_TrimAdjust` | (see disassembly) |
| 0x8DCF | `LinErr_Set` | Set a LIN error/response-error code |
| 0x8DDC | `LinApp_sub_8DDC` | (see disassembly) |
| 0x8DE6 | `LinSig_Request` | Request (re)publication of a LIN signal group |
| 0x8DEE | `LinApp_sub_8DEE` | (see disassembly) |
| 0x8E01 | `LinApp_SetErr` | (see disassembly) |
| 0x8E10 | `LinApp_Reset` | Reset the LIN application signal state |
| 0x8E35 | `LinApp_DecodeCommand` | Decode the received LIN command signals into app variables |
| 0x8E8B | `LinApp_Supervise` | LIN application supervision (command timeout) |
| 0x8EC7 | `LinApp_CountIdle` | (see disassembly) |
| 0x8ED5 | `LinDrv_Disable` | (see disassembly) |
| 0x8EDA | `LinSig_InitRx` | (see disassembly) |
| 0x8F18 | `LinSig_InitTx` | (see disassembly) |
| 0x8F6C | `LinSig_BuildStatus` | Build the periodic LIN status/response byte |
| 0x9118 | `LinSig_sub_9118` | (see disassembly) |
| 0x911E | `LinSig_RefreshTx` | (see disassembly) |
| 0x915F | `Sci_Init` | Initialise SCI1 for LIN (8N1), enable RX interrupt, TPM2 CH1 capture |
| 0x9185 | `Sci_SendByte` | Load one byte into SCI1 data register (start transmit) |
| 0x9195 | `Isr_Sci1` | SCI1 interrupt: RX byte / TX empty / error -> LIN byte engine |
| 0x9206 | `Isr_Tpm2Ch1_AutoBaud` | TPM2 CH1 input-capture ISR: measure LIN SYNC field, set SCI baud |
| 0x9305 | `LinTick_restore` | (see disassembly) |
| 0x9306 | `LinCrit_Enter` | LIN critical section enter (disable SCI RX int) |
| 0x931E | `LinCrit_Leave` | LIN critical section leave |
| 0x933E | `LinSci_DisIrq` | (see disassembly) |
| 0x9345 | `LinSci_RestIrq` | (see disassembly) |
| 0x934D | `LinTp_Reset` | Reset the LIN transport-protocol layer |
| 0x9361 | `LinTp_sub_9361` | (see disassembly) |
| 0x9396 | `LinTp_StartTimer` | Arm the transport-protocol timeout |
| 0x93CA | `LinTp_IsActive` | (see disassembly) |
| 0x93DC | `LinTp_RxFrame` | LIN transport: process a received TP frame (SF/FF/CF) |
| 0x9635 | `LinTp_TxFrame` | LIN transport: build a TP frame to transmit |
| 0x97B0 | `LinTp_sub_97B0` | (see disassembly) |
| 0x9806 | `LinTp_sub_9806` | (see disassembly) |
| 0x9843 | `Lin_Init` | Initialise the LIN slave stack and signals |
| 0x9868 | `Lin_ResetState` | Reset the LIN protocol state machine |
| 0x98A3 | `Lin_WakeOrReset` | (see disassembly) |
| 0x98F3 | `Lin_Supervise` | Periodic LIN timeout/supervision (bus idle, diag timers) |
| 0x9950 | `LinSig_PublishAll` | Publish all mapped LIN signals into the frame buffers |
| 0x998B | `LinSig_PublishAll2` | (see disassembly) |
| 0x99C9 | `Lin_ClearFrameState` | (see disassembly) |
| 0x99D8 | `Lin_GotoSleep` | Put the LIN stack into sleep state |
| 0x99EA | `Lin_GotoSleep2` | (see disassembly) |
| 0x99EC | `LinSched_OnHeader` | LIN schedule: decode a received PID and set up the frame |
| 0x9AB6 | `LinDiag_Response` | Build a diagnostic response frame (0x3D) |
| 0x9BA1 | `LinErr_Report` | Report a LIN frame error to the signal layer |
| 0x9C31 | `LinTp_Timer` | LIN transport + N_As/N_Cr timer tick (from the 1 ms ISR) |
| 0x9CCA | `LinSci_RxOn` | (see disassembly) |
| 0x9CD0 | `LinSci_RxOff` | (see disassembly) |
| 0x9CD4 | `LinSci_TxBreak` | (see disassembly) |
| 0x9CDE | `LinDiag_Request` | Start handling a diagnostic request frame (0x3C) |
| 0x9D44 | `LinCrc_Fold` | Fold the LIN enhanced-checksum carry |
| 0x9D62 | `Lin_RxByte` | LIN receive byte state machine (header/response/diagnostics) |
| 0x9E75 | `Lin_TxByteOrErr` | LIN transmit-byte / bus-error state machine |
| 0x9EF3 | `LinLL_Enable` | (see disassembly) |
| 0x9EFE | `LinLL_Disable` | (see disassembly) |
| 0x9F10 | `LinLL_sub_9F10` | (see disassembly) |
| 0x9F25 | `LinLL_sub_9F25` | (see disassembly) |
| 0x9F40 | `LinLL_Start` | (see disassembly) |
| 0x9F61 | `LinLL_Abort` | (see disassembly) |
| 0x9F6B | `LinLL_Classify` | (see disassembly) |
| 0x9FA9 | `LinLL_OnError` | (see disassembly) |
| 0x9FD1 | `LinLL_OnIdle` | (see disassembly) |
| 0x9FDB | `LinLL_Dispatch` | (see disassembly) |
| 0x9FEF | `LinTp_ResetCnt` | (see disassembly) |
| 0x9FF7 | `mem_fill_down` | (see disassembly) |
| 0xA019 | `mem_set` | memset helper |
| 0xA045 | `mem_copy` | memcpy helper |
| 0xA083 | `mem_copy_far` | far memcpy helper |
| 0xA0B0 | `sem_take` | (see disassembly) |
| 0xA0C7 | `sem_give` | (see disassembly) |
| 0xA0D9 | `crit_store` | (see disassembly) |
| 0xA0E0 | `crit_restore` | (see disassembly) |
| 0xA0E6 | `Sensor_Init` | Init the position/feedback sensor input |
| 0xA103 | `Adc_Read` | Read one ADC channel (8-bit), channel 0x1F powers the ADC down |
| 0xA12E | `Backlight_Init` | Init the backlight dimming controller |
| 0xA13A | `Backlight_SupplyStep` | (see disassembly) |
| 0xA1E6 | `Backlight_Start` | Start the controller |
| 0xA256 | `Backlight_Task` | Controller periodic step |
| 0xA25A | `Backlight_StepTimer` | (see disassembly) |
| 0xA5B5 | `Scan_Task` | Scroll/position periodic task |
| 0xA694 | `Backlight_SlowTask` | Controller slow periodic step |
| 0xA6F9 | `Scan_Init` | Init the button-ladder / scroll scan |
| 0xA719 | `Scan_Isr` | Button-ladder / scroll sampling + backlight PWM (1 ms) |
| 0xA874 | `Output_Stop` | (see disassembly) |
| 0xA88F | `Ladder_Reset` | (see disassembly) |
| 0xA8B6 | `Output_SelfTest` | (see disassembly) |
| 0xA91B | `Output_StallCheck` | (see disassembly) |
| 0xA957 | `Ladder_ReadRef` | (see disassembly) |
| 0xA99E | `BacklightOut_Init` | Init the backlight output stage |
| 0xA9A9 | `BacklightOut_Task` | Backlight output periodic task |
| 0xAA0C | `Status_SetCode` | Latch a fault code |
| 0xAA10 | `Buttons_Init` | Init fault handling |
| 0xAA36 | `Buttons_Scan` | Fault detection/debounce task |
| 0xAA68 | `Button_Debounce` | (see disassembly) |
| 0xAADD | `Button_Action` | (see disassembly) |
| 0xAB62 | `Button_Action2` | (see disassembly) |
| 0xAC81 | `LinSignals_Init` | Init the LIN signal mapping |
| 0xACB7 | `LinSignals_Refresh` | Recompute the LIN publish signals |
| 0xAE36 | `Signals_Task` | Map application state to LIN publish signals |
| 0xB415 | `Ports_Init` | Configure all GPIO directions, pull-ups and drive strengths |
| 0xB4D7 | `Diag_Task` | Diagnostics task |
| 0xB519 | `Ports_NvmPinLow` | Drive the NVM-activity pin (PTE7) low |
| 0xB521 | `Ports_NvmPinHigh` | Drive the NVM-activity pin (PTE7) high |
| 0xB529 | `Ports_PrepareSleep` | Switch I/O to the low-power state before STOP |
| 0xB53F | `Ports_AllInputs` | Make (almost) all ports inputs |
| 0xB55B | `Isr_Kbi` | Keyboard-interrupt (KBI) handler |
| 0xB5A3 | `Diag_Init` | Init diagnostics |
| 0xB5AA | `Diag_SlowTask` | Diagnostics slow task |
| 0xB620 | `Diag_sub_B620` | (see disassembly) |
| 0xB653 | `Delay_Loop` | Calibrated busy-wait (count in A:X) |
| 0xB667 | `Ramp_Limit` | (see disassembly) |
| 0xB7B8 | `EnterCritical` | Nestable interrupt-disable (global) |
| 0xB7C5 | `ExitCritical` | Nestable interrupt-enable (global) |
| 0xB7D9 | `Heating_Init` | Init the heater function |
| 0xB7E8 | `Heating_Task` | Heater control task |
| 0xB84D | `Inputs_Init` | Init and clear the input/signal variables |
| 0xB932 | `Supply_Init` | Init supply-voltage monitoring |
| 0xB9FD | `Supply_Task` | Measure and classify the supply voltage |
| 0xBA90 | `Supply_sub_BA90` | (see disassembly) |
| 0xBC54 | `ResetLog_Init` | Init the digital/PWM outputs |
| 0xBCB1 | `SelfTest_Task` | Update the outputs |
| 0xBEB7 | `Adc_sub_BEB7` | (see disassembly) |
| 0xBEC2 | `Adc_Init` | Init ADC then detect the hardware variant |
| 0xBEC7 | `Adc_DetectVariant` | Read the coding ADC channel and map it to variant+feature flags |
| 0xBFA7 | `Variant_ReadStraps` | Read the 5 coding/strap inputs into the coding byte |
| 0xC048 | `rotate3` | (see disassembly) |
| 0xC06C | `muls8` | (see disassembly) |
| 0xC078 | `muls8b` | (see disassembly) |
| 0xC0C5 | `negx` | (see disassembly) |
| 0xC0CB | `mul16` | 16x16 multiply helper |
| 0xC0E6 | `switch_jump` | Compiler helper: jump through a switch table |
| 0xC0F9 | `cmp32` | (see disassembly) |
| 0xC127 | `div16` | 16-bit divide helper |
| 0xC174 | `ldiv_init` | (see disassembly) |
