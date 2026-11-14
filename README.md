# MC9S08AW32 firmware — decompilation

Reverse-engineered C reconstruction of the firmware in
`2b5a8580-aw32.s19` (an S19 image for a Freescale/NXP **MC9S08AW32**
8-bit HCS08 microcontroller — the "S909AW32" part). The device is a
**LIN-bus slave node** (motor/output control module) with an in-system
**LIN bootloader** for field reprogramming.

> **Scope & honesty note.** This is ~18 KB of hand-written/compiled HCS08
> machine code, about 230 routines. The modules that matter most here —
> **LIN communication** and **ADC hardware-variant detection** — plus the
> startup, scheduler, time base, clock, flash-config and GPIO layers are
> reconstructed as commented C. The remaining application modules (closed-
> loop control, motor commutation, outputs, supply monitor, fault/diag and
> the deeper LIN transport/signal tables) and the whole bootloader are
> provided as a **complete, symbol-annotated disassembly** plus a function
> index, because a hand reconstruction of every routine cannot be
> guaranteed to reassemble to byte-identical code. The annotated assembly
> *is* the authoritative "same functionality" reference and lets any
> remaining routine be finished in C incrementally. See *Coverage* below.

## Layout

```
aw32_decompiled/
├── README.md                     this file
├── Makefile                      `make check` = host syntax check of the C
├── common/
│   └── mc9s08aw32.h              register map, bit masks, CPU helpers
├── application/                  the LIN-slave application (0x86E0+)
│   ├── app.h                     globals, Config layout, all prototypes
│   ├── main.c                    startup, scheduler, 1 ms time base, clock
│   ├── lin.c          ★          LIN driver: SCI1, break detect, auto-baud,
│   │                             RX/TX byte engines, init/supervise
│   ├── adc.c          ★          ADC driver + hardware-variant detection
│   ├── nvm.c                     flash configuration storage (dual bank)
│   ├── ports.c                   GPIO setup, critical sections
│   ├── util.c                    calibrated delay
│   └── vectors.c                 interrupt vector mapping
├── bootloader/
│   └── bootloader_notes.md       reset logic, vector ownership, download protocol
└── reference/
    ├── application.asm           full annotated disassembly (app)
    ├── bootloader.asm            full annotated disassembly (bootloader)
    └── function_index.md         every routine: address, name, purpose
```
★ = the two subsystems you asked to prioritise.

## How the device works

* **Reset** enters the bootloader at `0xF400`, which validates the
  application (entry word at `0xF3FE` = `0x86E0`) and jumps to it, or stays
  in the download protocol on a cold power-on / blank app. The bootloader
  owns the real vectors and forwards interrupts to the application handlers
  listed at `0xF3CC` (see `bootloader/bootloader_notes.md`).
* **Application startup** (`App_Startup`, 0x86E0) copies initialised data
  from flash, zeros RAM and calls `main()`.
* **`main()`** runs `App_InitAll()` then loops: wait for the 1 ms tick flag
  (set by the TPM2-CH0 compare ISR), run the cooperative `Scheduler_Run()`.
  The scheduler fans out into 2/5/10/25-tick tasks.
* **Hardware variant** is read once at init from a coding resistor on
  ADC channel `0x0B` (`Adc_DetectVariant`), which sets `g_featureFlags`
  (motor / heater / … enables) and, out of range, `g_testMode`.
* **LIN** runs on SCI1. Each frame starts with a BREAK (detected as an SCI
  framing error with data 0) and a SYNC field whose length is measured by a
  TPM2-CH1 input capture to set the baud rate automatically
  (`Isr_Tpm2Ch1_AutoBaud`). Bytes are processed in the SCI ISR by two state
  machines (`Lin_RxByte` / `Lin_TxByteOrErr`) feeding the schedule,
  diagnostic transport and signal layers.
* **Configuration** lives in two 512-byte flash banks (0x8000 / 0x8200);
  the newest valid bank (lowest write counter, checksum == 0xCAFE) is used
  and saved with RAM-resident flash routines (`nvm.c`).

## Memory map (MC9S08AW32)

| Range | Use |
|-------|-----|
| 0x0000–0x006F | direct-page peripheral registers |
| 0x0070–0x086F | RAM (2 KB) — globals, stack (SP top 0x086F) |
| 0x0120–0x019F | `g_cfg` configuration image (RAM copy) |
| 0x1800–0x185F | high-page registers (SRS, SOPT, flash, port control) |
| 0x8000 / 0x8200 | config flash bank A / B (512 B each) |
| 0x86E0–0xC24F | application code |
| 0xC17D–0xC24F | application const tables (schedule, variant, strap) |
| 0xF3CC–0xF3FF | bootloader→app vector redirect table |
| 0xF400–0xFE73 | bootloader code |
| 0xFFB0–0xFFBF | NV registers (ICG trim at 0xFFBE, etc.) |
| 0xFFC0–0xFFFF | CPU vector table (owned by the bootloader) |

## Building / verifying

```bash
make check     # validates every application .c as well-formed C (host gcc)
```

For a real target image use **CodeWarrior for HC(S)08** (the original
toolchain). A best-effort `make sdcc` target is provided, but SDCC's s08
support, the `__interrupt` convention and the RAM-resident flash routines
would each need review before an SDCC build matched the original behaviour.
The register header supports both toolchains (`__SDCC` vs. CodeWarrior).

## Coverage

| Area | Form |
|------|------|
| Startup, scheduler, time base, clock, STOP/sleep | reconstructed C (`main.c`) |
| LIN SCI driver, break/auto-baud, SCI & capture ISRs, init/supervise | reconstructed C (`lin.c`) |
| LIN byte RX/TX engines, transport & signal layers | C dispatch skeleton in `lin.c` + full detail in `reference/application.asm` |
| ADC read + variant/feature detection, strap coding | reconstructed C (`adc.c`) |
| Flash dual-bank configuration store | reconstructed C (`nvm.c`) |
| GPIO, critical sections, delay | reconstructed C (`ports.c`, `util.c`) |
| Control, motor, outputs, supply, fault, diag, sensor, heater | annotated disassembly + function index |
| Bootloader (download protocol, RAM flash routines) | annotated disassembly + notes |

Every routine — reconstructed or not — appears in
`reference/function_index.md` with its address, name and purpose, and in
the annotated `.asm` listings with the same symbolic names used in the C.
```
