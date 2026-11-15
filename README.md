# MC9S08AW32 firmware — decompilation

Reverse-engineered **C reconstruction** of the firmware in
`firmware/2b5a8580-aw32.s19` (an S19 image for a Freescale/NXP
**MC9S08AW32** 8-bit HCS08 microcontroller — the "S909AW32" part).

The device is the **multifunction steering-wheel button panel of an Audi
A4 B8** — a **LIN-bus slave** that scans the wheel buttons (an analogue
resistor ladder), decodes the scroll/roll wheel, drives the button
backlighting (PWM) and, on the equipped variants, the steering-wheel
heating. It talks over LIN to the steering-column module and carries an
in-system **LIN bootloader** for field reprogramming. See `DEVICE.md` for
the functional map, the feature-coding resistor and the variant table.

> **Status.** The whole image (~18 KB, ~230 routines) has been reconstructed
> as commented C — the application **and** the bootloader (including the
> reflash command handlers). `make check` compiles every source as
> well-formed C. A handful of the deepest table-walk bodies (the per-byte
> brightness-curve interpolation, a couple of descriptor/action handlers and
> the compiler's `crt0` copy loop) are summarised in C with the exact bytes
> cross-referenced to `reference/*.asm`, which stays the byte-exact ground
> truth. `PROGRESS.md` tracks every module's state.

## Layout

```
.
├── README.md                 this file
├── DEVICE.md                 what the device is + per-module function map + variant table
├── PROGRESS.md               per-routine reconstruction status / how to resume
├── Makefile                  `make check` = host syntax check of the C
├── firmware/
│   └── 2b5a8580-aw32.s19     the original firmware image
├── common/
│   └── mc9s08aw32.h          register map, bit masks, CPU helpers
├── application/              the LIN-slave application (0x86E0+)
│   ├── app.h                 globals, Config layout, all prototypes
│   ├── main.c                startup, scheduler, 1 ms time base, clock, sleep
│   ├── lin.c                 LIN driver: SCI1, break detect, auto-baud, RX/TX byte engines, TP timer
│   ├── lin_transport.c       LIN schedule + diagnostics + ISO-TP (SF/FF/CF) + error mapping
│   ├── lin_signals.c         LIN signal layer: command decode, status build, publish
│   ├── adc.c                 ADC driver + steering-wheel variant/feature detection
│   ├── sensor.c              ADC analogue front-end config
│   ├── buttons.c             steering-wheel button scan + shift-register debounce
│   ├── wheel_io.c            backlight dimming FSM, scroll/ladder scan, output stage
│   ├── heating.c             steering-wheel heating (NTC + ramped output)
│   ├── supply.c              KL30 supply-voltage monitoring
│   ├── signals.c             publish-signal state + age counters
│   ├── diag.c                diagnostics / output-stage test
│   ├── selftest.c            reset-cause logging + background flash CRC self-test
│   ├── inputs.c              input/signal-state initialisation
│   ├── nvm.c                 flash configuration storage (dual bank)
│   ├── ports.c               GPIO setup, nestable critical sections
│   ├── runtime.c             compiler runtime helpers (mem/mul/div)
│   ├── util.c                calibrated delay
│   └── vectors.c             interrupt vector mapping
├── bootloader/               the resident LIN bootloader (0xF400+)
│   ├── bootloader.c          reset/launch, command loop, SCI FIFOs, clock, CRC, timer
│   ├── reflash.c             the reflash command handlers (E/I/D/F/Q/R/C/V/W/L)
│   ├── protocol.md           exact SCI wire protocol (handshake, commands, frame format)
│   └── bootloader_notes.md   reset logic, vector ownership, overview
└── reference/
    ├── application.asm        full symbol-annotated disassembly (app)
    ├── bootloader.asm         full symbol-annotated disassembly (bootloader)
    └── function_index.md      every routine: address, name, purpose
```

## How the device works

* **Reset** enters the bootloader at `0xF400`, which validates the
  application (entry word at `0xF3FE` = `0x86E0`) and jumps to it, or stays
  in the download protocol on a cold power-on / blank app. The bootloader
  owns the real vectors and forwards interrupts to the application handlers
  listed at `0xF3CC` (see `bootloader/`).
* **Application startup** (`App_Startup`, 0x86E0) copies initialised data
  from flash, zeros RAM and calls `main()`.
* **`main()`** runs `App_InitAll()` then loops: wait for the 1 ms tick flag
  (set by the TPM2-CH0 compare ISR), run the cooperative `Scheduler_Run()`,
  which fans out into 2/5/10/25-tick tasks.
* **Steering-wheel variant** is read once at init from a coding resistor on
  ADC channel `0x0B` (`Adc_DetectVariant`), which sets `g_featureFlags`
  (buttons / heating / scroll+backlight enables) and, out of range,
  `g_testMode`. See `DEVICE.md` for the variant/resistor table.
* **Buttons** are an analogue resistor ladder (ADC ch 2) plus GPIO inputs,
  debounced with a 4-sample shift register (`buttons.c`); the scroll wheel
  and the backlight PWM dimming are handled in `wheel_io.c`.
* **LIN** runs on SCI1. Each frame starts with a BREAK (detected as an SCI
  framing error with data 0) and a SYNC field whose length is measured by a
  TPM2-CH1 input capture to set the baud rate automatically
  (`Isr_Tpm2Ch1_AutoBaud`). Bytes are processed in the SCI ISR by two state
  machines (`Lin_RxByte` / `Lin_TxByteOrErr`) feeding the schedule,
  diagnostic transport (ISO-TP) and signal layers. The node **publishes**
  button/scroll state and **subscribes** to the backlight dimming level.
* **Configuration** lives in two 512-byte flash banks (0x8000 / 0x8200);
  the newest valid bank (lowest write counter, checksum == 0xCAFE) is used
  and saved with RAM-resident flash routines (`nvm.c`).
* **Reflash:** the bootloader never contains flash-program code — the host
  downloads a programmer into RAM, it is CRC-checked and run via `jsr`
  (`bootloader/protocol.md`).

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
make check     # validates every .c (application + bootloader) as well-formed C (host gcc)
```

For a real target image use **CodeWarrior for HC(S)08** (the original
toolchain). A best-effort `make sdcc` target is provided, but SDCC's s08
support, the `__interrupt` convention and the RAM-resident flash routines
would each need review before an SDCC build matched the original behaviour.
The register header supports both toolchains (`__SDCC` vs. CodeWarrior).

> These are reconstructed sources: they reproduce the firmware's logic,
> hardware access, tables and wire formats, but a rebuild is not guaranteed
> to reassemble to byte-identical code. For bit-exact reference always use
> `firmware/2b5a8580-aw32.s19` and `reference/*.asm`.

## Coverage

Every application and bootloader module is reconstructed as commented C
(`make check` passes). What remains cross-referenced to `reference/*.asm`
rather than fully inlined in C:

| Area | Form |
|------|------|
| Startup, scheduler, time base, clock, STOP/sleep | reconstructed C (`main.c`) |
| LIN driver, break/auto-baud, ISRs, byte engines, TP timer | reconstructed C (`lin.c`) |
| LIN schedule, diagnostics, ISO-TP SF/FF/CF, error mapping | reconstructed C (`lin_transport.c`) |
| LIN command decode / status build / publish | reconstructed C (`lin_signals.c`, `signals.c`) |
| ADC + variant/feature detection, button ladder, strap coding | reconstructed C (`adc.c`, `sensor.c`) |
| Button scan + debounce | reconstructed C (`buttons.c`) |
| Backlight dimming FSM (12 states), scroll/ladder scan, output stage | reconstructed C (`wheel_io.c`) |
| Steering-wheel heating, supply monitor, diagnostics, inputs, reset-log/self-test | reconstructed C (`heating.c`, `supply.c`, `diag.c`, `inputs.c`, `selftest.c`) |
| Flash dual-bank config store, GPIO, runtime helpers, delay | reconstructed C (`nvm.c`, `ports.c`, `runtime.c`, `util.c`) |
| Bootloader: reset/launch, command loop, SCI, CRC, reflash handlers | reconstructed C (`bootloader/`) |
| Heating-curve interpolation, supply brightness compensation, aux-channel sampling, crt0 copy, status bit-packing | reconstructed C (full) |

Every routine — reconstructed or not — appears in
`reference/function_index.md` with its address, name and purpose, and in the
annotated `.asm` listings with the same symbol names used in the C.
