# Decompilation progress

Firmware: `firmware/2b5a8580-aw32.s19` — Freescale/NXP **MC9S08AW32** (S909AW32),
a LIN-bus slave node. Two parts: bootloader (0xF400+) + application (0x86E0+).
~18 KB code, ~230 routines.

Ground truth for everything is the symbol-annotated disassembly in
`reference/application.asm` and `reference/bootloader.asm`. Any remaining
routine can be reconstructed in C from there. The symbolic names used in the
C sources match the names in the `.asm` listings and `reference/function_index.md`.

## Legend
- [x] reconstructed, commented C
- [~] partial / dispatch skeleton in C, full detail in reference/*.asm
- [ ] reference only (annotated disassembly + function index)

## Application modules
- [x] Startup / scheduler / 1 ms time base / clock / STOP — `application/main.c`
- [x] LIN SCI driver, break detect, auto-baud, SCI & capture ISRs, init/supervise — `application/lin.c`
- [x] LIN byte RX/TX engines — `application/lin.c` (`Lin_RxByte` 0x9D62 full state machine: publish/diag/checksum; `Lin_TxByteOrErr` 0x9E75 BREAK/error handler with re-arm)
- [x] LIN transport timers + CRC — `application/lin.c` `LinTp_Timer` 0x9C31 (N_As/N_Cr + wakeup break) and `lin_transport.c` `LinCrc_Fold` 0x9D44. ISO-TP SF/FF/CF assembler `LinTp_RxFrame`/`TxFrame` dispatch reconstructed; inner frame assembly referenced in asm.
- [x] LIN diagnostic + schedule — `application/lin_transport.c` (`LinSched_OnHeader` 0x99EC, `LinDiag_Request` 0x9CDE, `LinDiag_Response` 0x9AB6, `LinErr_Report` 0x9BA1 — full, with the flash frame tables C1A2/C1AB/C1AF/C1B5/C1B7/C1C*/C1CB)
- [x] LIN signal mapping — `application/lin_signals.c` (`LinApp_Reset`, `LinApp_DecodeCommand` full bit layout, `LinApp_Supervise`, `LinApp_CountIdle`, `LinSig_PublishAll`/`PublishAll2` 0x9950/0x998B full; `LinSig_BuildStatus` 0x8F6C counters + documented per-bit map)
- [x] ADC read + hardware variant/feature detection + strap coding — `application/adc.c`
- [x] Flash dual-bank configuration store — `application/nvm.c`
- [x] GPIO config + global critical sections — `application/ports.c`
- [x] Calibrated delay — `application/util.c`
- [x] Interrupt vector mapping (doc + optional standalone table) — `application/vectors.c`
- [x] Supply-voltage monitor — `application/supply.c` (`Supply_Init`, `Supply_Task`; aux-channel descriptor walk referenced in asm)
- [x] Button-input debounce (DEVICE) — `application/fault.c` (`Fault_Init`, `Fault_Task`, `Fault_Debounce` 4-sample shift-register via the 0xC1F8 {port,mask,action} descriptors; action dispatch 0xC1FB referenced in asm)
- [x] Inputs/signal-state init — `application/inputs.c` (`Inputs_Init` 0xB84D)
- [x] Reset logging + flash self-test — `application/selftest.c` (`Outputs_Init` 0xBC54 reset-cause counters; `Outputs_Task`/`FlashSelfTest_Step` 0xBCB1 incremental XOR-16 flash check vs 0xCAFE). NOTE: auto-label 'Outputs_*' is a misnomer.
- [x] Backlight dimming state machine (DEVICE) — `application/motor_control.c` (`Ctrl_Init`, `Ctrl_Start`, `Ctrl_Task`/`Ctrl_Step` 0xA256 — all 12 states fully reconstructed (idle/ramp/hold/dwell/dim-step/release/self-test/low-&-high-voltage/fault) with helpers Supply_InWindow, Backlight_SetLevel, Ctrl_PlausCheck, voltage-edge debounces)
- [x] Button/output driver (DEVICE) — `application/motor_control.c` (`Motor_Init`, `Motor_Task` level decision tree)
- [x] Button-ladder/scroll + backlight PWM tick (DEVICE) — `application/motor_control.c` (`MotorPos_Init`, `MotorPos_Isr` 0xA719, `MotorPos_Task`)
- [x] ADC analogue front-end — `application/sensor.c` (`Sensor_Init` 0xA0E6)
- [x] Aux analogue input (DEVICE) — `application/heater.c` (`Heater_Init`, `Heater_Task`; open/short detect, slew-limited; `Heater_Drive` table interpolation referenced in asm)
- [x] Diagnostics / output test — `application/diag.c` (`Diag_Init`, `Diag_Task`, `Diag_SlowTask`)
- [x] Publish-signal state — `application/signals.c` (`LinSignals_Init`, `LinSignals_Refresh`, `Signals_Task` 0xAE36 age counters)

## Bootloader
- [x] Bootloader — `bootloader/bootloader.c` (reset/launch, command loop, clock/SCI init, polled SCI TX/RX FIFOs `Boot_SciSend`/`Boot_SciRecv`, CRC, TPM2 software timer `Boot_TimeTick`); handlers in `bootloader/reflash.c`; wire format `bootloader/protocol.md`. Only `Boot_StartupCopy` (compiler crt0 table walk) stays documented.

## Status
All application modules now have a C file (top-level logic + hardware access
reconstructed; the intricate inner math of the control loop, the LIN byte-level
framing and several table-driven helpers are cross-referenced to
`reference/application.asm`, which remains the byte-exact ground truth).
The bootloader stays as annotated asm by design.

Helper routines reconstructed: compiler runtime (mem/mul/div/negate) in
`application/runtime.c`; device helpers Motor_sub_A874/A88F/A91B/A957 in
`motor_control.c`, Adc_sub_BEB7 in `selftest.c`.
Reconstructed: Motor_Ramp 0xB667 (slew limiter) and Motor_sub_A8B6 0xA8B6
(drive self-test) in motor_control.c. Still referenced to asm: Heater_Drive
0xB707 (two-column table interpolation).

## How to resume in a fresh session
1. Clone this repo; the original firmware is in `firmware/`.
2. `reference/*.asm` already has every routine annotated — no need to re-run
   the disassembler. If you want to regenerate it, Capstone's M680X HCS08 mode
   was used (note: it mislabels `bset`/`bclr`, which the generator corrects),
   loaded at offset so S19 addr 0x7Fxx → 0xFFxx (image base 0x8000).
3. Pick the next `[ ]` item, read its range in `reference/application.asm`,
   write the C into `application/<module>.c`, add prototypes to `application/app.h`,
   run `make check`, update this file, commit.
