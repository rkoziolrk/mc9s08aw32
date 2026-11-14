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
- [~] LIN byte RX/TX engines (`Lin_RxByte` 0x9D62, `Lin_TxByteOrErr` 0x9E75) — `application/lin.c`
- [ ] LIN transport layer (`LinTp_RxFrame` 0x93DC, `LinTp_TxFrame` 0x9635, `LinTp_Timer` 0x9C31)
- [ ] LIN diagnostic layer (`LinDiag_Request` 0x9CDE, `LinDiag_Response` 0x9AB6, `LinSched_OnHeader` 0x99EC)
- [~] LIN signal mapping — `application/lin_signals.c` (`LinApp_Reset` 0x8E10, `LinApp_DecodeCommand` 0x8E35 with full command bit layout, `LinApp_Supervise` 0x8E8B, `LinApp_CountIdle` 0x8EC7; `LinSig_BuildStatus` 0x8F6C and `LinSig_PublishAll` 0x9950/0x998B publish tables referenced in asm)
- [x] ADC read + hardware variant/feature detection + strap coding — `application/adc.c`
- [x] Flash dual-bank configuration store — `application/nvm.c`
- [x] GPIO config + global critical sections — `application/ports.c`
- [x] Calibrated delay — `application/util.c`
- [x] Interrupt vector mapping (doc + optional standalone table) — `application/vectors.c`
- [~] Supply-voltage monitor — `application/supply.c` (`Supply_Init` 0xB932, `Supply_Task` 0xB9FD; aux-channel descriptor walk referenced in asm)
- [~] Fault handling — `application/fault.c` (`Fault_Init` 0xAA10, `Fault_Task` 0xAA36, `Fault_Report` 0xAA0C; descriptor-table read + action dispatch referenced in asm)
- [x] Inputs/signal-state init — `application/inputs.c` (`Inputs_Init` 0xB84D)
- [~] Reset logging + flash self-test — `application/selftest.c` (`Outputs_Init` 0xBC54 = reset-cause counters + variant select; `Outputs_Task` 0xBCB1 = incremental flash CRC, walk referenced in asm). NOTE: auto-label 'Outputs_*' is a misnomer; real purpose documented.
- [ ] Controller — `Ctrl_Init` 0xA12E, `Ctrl_Start` 0xA1E6, `Ctrl_Task` 0xA256, `Ctrl_SlowTask` 0xA694
- [ ] Motor driver — `Motor_Init` 0xA99E, `Motor_Task` 0xA9A9
- [ ] Motor position / commutation — `MotorPos_Init` 0xA6F9, `MotorPos_Isr` 0xA719, `MotorPos_Task` 0xA5B5
- [ ] Sensor input — `Sensor_Init` 0xA0E6
- [ ] Heater — `Heater_Init` 0xB7D9, `Heater_Task` 0xB7E8
- [ ] Diagnostics — `Diag_Init` 0xB5A3, `Diag_Task` 0xB4D7, `Diag_SlowTask` 0xB5AA
- [ ] Signals mapping — `Signals_Task` 0xAE36, `LinSignals_Init` 0xAC81, `LinSignals_Refresh` 0xACB7

## Bootloader
- [ ] Reset/launch + download protocol + RAM flash routines — `reference/bootloader.asm`,
      `bootloader/bootloader_notes.md` (intentionally kept as annotated asm;
      RAM-resident flash code cannot be guaranteed byte-identical from C).

## Planned order
Supply → Fault → Inputs/Outputs → LIN transport/diag/signal layers → Control/Motor.

## How to resume in a fresh session
1. Clone this repo; the original firmware is in `firmware/`.
2. `reference/*.asm` already has every routine annotated — no need to re-run
   the disassembler. If you want to regenerate it, Capstone's M680X HCS08 mode
   was used (note: it mislabels `bset`/`bclr`, which the generator corrects),
   loaded at offset so S19 addr 0x7Fxx → 0xFFxx (image base 0x8000).
3. Pick the next `[ ]` item, read its range in `reference/application.asm`,
   write the C into `application/<module>.c`, add prototypes to `application/app.h`,
   run `make check`, update this file, commit.
