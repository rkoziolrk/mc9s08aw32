# Device identity and functional map

**This firmware is the MCU of the multifunction steering-wheel button panel
of an Audi A4 B8** (NXP/Freescale MC9S08AW32, "S909AW32"). It is a **LIN
slave** that:

* scans the steering-wheel **buttons** (read as an analogue resistor ladder
  on the ADC, not a key matrix),
* decodes the **scroll/roll wheel** (volume up / down),
* drives the **button backlighting** (PWM dimming, faded smoothly), and
* communicates over **LIN** with the steering-column control module
  (steering-angle sensor / turn-signal & wiper stalk module), to which it
  reports button/scroll events and from which it receives the backlight
  dimming level.

> Naming note. The function/file names in the C sources are the real,
> device-accurate ones.  The raw hex addresses in `reference/*.asm` are the
> byte-exact ground truth; this file explains what each module does.  (An
> earlier revision used motor-themed placeholder names — they have all been
> renamed to the names below.)

## Modules and what they do

| File / symbol | **Function** |
|---------------|--------------|
| `adc.c` `Adc_DetectVariant` (ch 0x0B) | **start-up option coding** — one read of the ch 0x0B rail → `g_featureFlags` (which options are fitted); see the coding section below |
| `adc.c` `Adc_Read` (ch 2) | reads the **button resistor ladder** voltage |
| `wheel_io.c` `Backlight_*` | the **backlight dimming** state machine (brightness ramp toward the commanded level) |
| `wheel_io.c` `Scan_Isr` (1 ms) | **button-ladder / scroll sampling + backlight PWM update** tick |
| `wheel_io.c` `Ladder_*` 0x0241/0x0242 | **button-ladder reference / threshold levels** (per-button calibration) |
| `wheel_io.c` `Output_SelfTest` / `Output_StallCheck` | drive **PTE2 (pin 10, a NO-CONNECT on this board)** and read ADC ch 0x0A/0x02 → fault code; validates no real load here (vestigial/generic actuator stage) |
| `wheel_io.c` `Ramp_Limit` (0xB667) | **backlight brightness fade** (and supply filtering) — slew-rate limiter |
| `main.c` `Tpm1_Init` (TPM1 CH1 PWM) | **backlight LED PWM** (brightness) |
| `heating.c` `Heating_*` | **steering-wheel heating** — NTC on ADC ch 3 (open/short detect) + ramped output (feature bit 0x02) |
| `supply.c` `Supply_*` | **KL30 supply-voltage monitoring** |
| `lin_signals.c` `LinApp_DecodeCommand` `CMD_LEVEL` (rx byte C7) | **backlight dimming level received** from the bus (instrument-cluster dimmer) |
| `lin_signals.c` published signals | **button states + scroll counter** published to the column module |
| `lin*.c` diagnostic transport | LIN diagnostic **ISO-TP transport** (NAD 0x0A) — transport + accept/reject only, no per-service dispatcher (see `reference/lin_frames.md`) |
| `selftest.c` `ResetLog_Init` / `SelfTest_Task` | **reset-cause logging** + background flash CRC self-test |
| `buttons.c` `Buttons_Scan` / `Button_Debounce` | **steering-wheel button scan** (GPIO inputs, 4-sample shift-register debounce) |

## LIN signal picture

* **Publish (slave → master/column module):** button-press bitmap, scroll
  (roll) increment/decrement counter, and node status. Built by
  `signals.c` / `LinSig_BuildStatus` from the debounced inputs.
* **Subscribe (master → this node):** backlight **dimming level** and
  enable, decoded by `LinApp_DecodeCommand` (bytes 0x01C5..0x01C8) into the
  backlight / state variables.

The complete frame list (IDs/PIDs, directions, byte layouts, the diagnostic
ISO-TP response and node NAD `0x0A`) is in
[`reference/lin_frames.md`](reference/lin_frames.md).  Note: the diagnostic
channel implements the transport + accept/reject only — there is **no**
per-service (read-by-identifier / assign-NAD) dispatcher in the image.

Everything else in `README.md` (memory map, bootloader, build, coverage)
still applies; this file only corrects *what the firmware is for*.

## Start-up option coding (ADC ch 0x0B + digital straps)

At power-up `Adc_DetectVariant` (0xBEC7) takes **one** 8-bit reading of ADC
channel **0x0B** and classifies it into discrete windows.  The only value
used afterwards is the feature bitmask **`g_featureFlags`** (0x0299).

> **Not a stored variant id.** The function also writes `g_variantCode`
> (0x02EC) and `g_variantSub` (0x02EB), but **nothing in the image ever reads
> them** — they are dead/diagnostic.  There is no enumerated "variant number";
> only the feature *bits* drive behaviour.  A reading outside every window
> sets `g_testMode` (0x02EA) and the gated subsystems stay off.

**Physical source (board-level).** Channel 0x0B = AD11 = **PTD3 = pin 32**.
On this board that pin is wired, through series resistors, to the **common
emitter of the TCUT1350X01** transmissive optical sensor (the scroll-wheel
quadrature encoder).  The boot read therefore samples the *resting DC level*
of that rail; whichever window it lands in (set by the series-resistor network
/ which options are populated) selects the feature set.  This is best read as
**option/presence detection at power-up**, not a coding-resistor "variant id";
the exact divider topology on that rail is not provable from the firmware.  A
second, digital leg of the coding — `Variant_ReadStraps` (0xBFA7) — samples
strap pins via the table at flash 0xC245 into `g_codingByte` (0x0298), used by
the LIN identification signals.

### Feature bits (`g_featureFlags`) — verified from every gate

| Bit | Enables | Evidence (gate sites) |
|-----|---------|-----------------------|
| **0x01** `FEAT_OPT_BUTTONS` | optional button positions **4,5,8,9** in `Buttons_Scan` (without it those four are skipped) + their LIN signals | AA45, AD0C/AE66, 908B, B8EA |
| **0x02** `FEAT_HEATER` | steering-wheel **heating**: `Heating_Task` (NTC on ch 0x03), output loop `sub_AF21`, LIN RX init + status | 87B8, 88E8/890D, 8EF5/8FFD/90B6, AFBC..B2D3, B913 |
| **0x04** `FEAT_SCROLL` | **scroll/roll wheel + illumination controller**: gates `Scan_Init` + `Backlight_Start` at boot and their 10-tick tasks | 87A6, 88A8/891C, B902 |
| **0x08** `FEAT_RESERVED` | **nothing** — set in some windows but no code path tests it | (no gate site anywhere) |

> Bit 0x01 is firm (it selectively enables four otherwise-ignored button
> positions).  0x02 (heating) and 0x04 (scroll) are reverse-engineering
> inferences — no strings in the image — but well grounded: 0x02 enables an
> NTC + ramped-output chain (classic heated wheel), 0x04 enables the encoder
> scan + illumination controller.  0x08 is set in several windows yet is
> never tested, so it carries no equipment.

### Coding windows (ADC ground truth)

The window edges below are exactly the compares in the firmware; `flags` is
the `g_featureFlags` value each window latches.  (8-bit ADC; at Vref = 5.0 V,
U ≈ code/255 × 5 V — given only as a rough level.  Back-computed resistor
values are **omitted on purpose**: the rail is the TCUT1350X01 emitter
network, not a plain coding divider, so any ohm figure would be guesswork.)

| ADC window | flags | U centre [V] | equipment implied |
|:----------:|:-----:|:------------:|:------------------|
| 0x11–0x18 | 0x00 | ~0.41 | base buttons only |
| 0x1D–0x25 | 0x02 | ~0.65 | + heating |
| 0x2A–0x33 | 0x01 | ~0.92 | + optional buttons |
| 0x39–0x43 | 0x03 | ~1.22 | optional buttons + heating |
| 0x6A–0x76 | 0x08 | ~2.20 | base (reserved bit only) |
| 0x7C–0x89 | 0x09 | ~2.57 | optional buttons (+reserved) |
| 0x8E–0x9D | 0x0F | ~2.94 | optional buttons + heating + scroll |
| 0xA3–0xB1 | 0x0C | ~3.33 | scroll (+reserved) |
| 0xB7–0xC8 | 0x0B | ~3.76 | optional buttons + heating (+reserved) |
| outside all | — | — | `g_testMode` = 1 (coding fault, gated subsystems off) |

### Equipment summary

* Base buttons, the resistor ladder and LIN are **always present** (not gated).
* **Optional buttons** (positions 4,5,8,9) = bit 0x01; **heating** = bit 0x02;
  **scroll wheel + illumination controller** = bit 0x04.  Bit 0x08 carries no
  equipment (never tested).
* **Fullest set** = flags 0x0F (0x8E–0x9D window): optional buttons + heating
  + scroll.  **Heating** is present in any window with bit 0x02 set (0x1D,
  0x39, 0x8E, 0xB7).
* The scroll encoder's **motion** is decoded continuously on its own channels
  in `Scan_Isr` (1 ms); the one-shot ch 0x0B read above is unrelated to motion.

## Illumination (backlight) control

The button backlight is **not** on PTE2 (pin 10 / TPM1CH0) — that pin is a
NO-CONNECT and its `Output_*` self-test (see below) drives nothing.  The real,
dimmable illumination is a **TPM1 PWM commanded over LIN**:

```
cyclic subscribed LIN frame
  → LinApp_DecodeCommand (0x8E35): RX buffer 0x01C5..0x01C8 → signals 0x028E..0x0296
  → backlight controller: 0x028F → duty params 0x02B3/0x02B4 (level 0x02B2)
  → Isr_Kbi (0xB55B): TPM1C2V = 0xC8 − f(0x02B4)      (TPM1MOD = 0xC8)
  → PWM out on TPM1CH2 = PTF0 = pin 4
```

* **Main dimmable output: `TPM1CH2` / `PTF0` / pin 4.** The enable path
  (`sub_B5E4`) switches PTF0 from GPIO to PWM (`TPM1C2SC = 0x24`,
  `TPM1C2V = 0xC8`); the off path (`Diag_sub_B620`/`sub_B639`) clears
  `TPM1C2SC` and returns PTF0 to GPIO.  Brightness = `0xC8 − f(0x02B4)`, and
  `0x02B4` comes from the decoded LIN byte `0x028F`.
* **Default with no LIN traffic = full brightness.** With no frame, `0x028F`
  stays 0 → `0x02B4 = 0` → `TPM1C2V = 0xC8` (and `Tpm1_Init` already sets
  `TPM1C2V = 0xC8`).  So the panel lights at full until the bus commands a
  dimmer level — matches the observed power-on behaviour.
* **`LinErr_Set` fallback.** A framing error *during* communication forces
  `0x02B2 = 0x50` (a defined mid level) — distinct from the no-traffic case.
* **Strap `PTC4` (pin 1) → `g_outputVariant` (0x0275).** Read at runtime
  (`brclr 4,PTCD`): **PTC4 = VDD → `g_outputVariant = 1`**, which *additionally*
  enables a **second output `TPM1CH1` / `PTE3` / pin 11 at a fixed ~50% duty**
  (`TPM1C1SC = 0x24`, `TPM1C1V = 0x64`).  With PTC4 low that channel stays off.
  So PTC4 is not a pin selector — it adds the fixed-brightness PTE3 output
  alongside the LIN-dimmed PTF0 one.  (On the inspected board PTC4 = VDD.)

### Output self-test stage (`Output_*`) — vestigial here

`Backlight_Start` (gated by feature bit 0x04) also runs `Output_Stop` /
`Output_StallCheck` / `Output_SelfTest`, which toggle **PTE2 = pin 10
(TPM1CH0)** and read ADC feedback (ch 0x0A supply, ch 0x02 ladder), raising a
fault code on an implausible ratio.  **PTE2 is a NO-CONNECT on this board**, so
this stage drives no physical load and validates nothing real — effectively
vestigial/generic actuator code (consistent with a shared image, and with why
the firmware first looked like a motor controller).  The firmware therefore
performs **no** button-LED health check.

## Pinout

The 44-pin LQFP package pin assignment and the ADC channel→pin usage are in
[`reference/pinout.md`](reference/pinout.md).  The start-up coding ADC is on
`PTD3` (AD1P11) = pin 32, wired (per board) to the TCUT1350X01 common emitter;
`PTE2` = pin 10 is a no-connect.
