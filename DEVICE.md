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
| `adc.c` `Adc_DetectVariant` (ch 0x0B) | **steering-wheel coding** — which button set / wheel type is fitted; selects the feature set |
| `adc.c` `Adc_Read` (ch 2) | reads the **button resistor ladder** voltage |
| `wheel_io.c` `Backlight_*` | the **backlight dimming** state machine (brightness ramp toward the commanded level) |
| `wheel_io.c` `Scan_Isr` (1 ms) | **button-ladder / scroll sampling + backlight PWM update** tick |
| `wheel_io.c` `Ladder_*` 0x0241/0x0242 | **button-ladder reference / threshold levels** (per-button calibration) |
| `wheel_io.c` `Output_SelfTest` / `Output_StallCheck` | **ladder plausibility / stuck-button / short detection** (current vs feedback) |
| `wheel_io.c` `Ramp_Limit` (0xB667) | **backlight brightness fade** (and supply filtering) — slew-rate limiter |
| `main.c` `Tpm1_Init` (TPM1 CH1 PWM) | **backlight LED PWM** (brightness) |
| `heating.c` `Heating_*` | **steering-wheel heating** — NTC on ADC ch 3 (open/short detect) + ramped output (feature bit 0x02) |
| `supply.c` `Supply_*` | **KL30 supply-voltage monitoring** |
| `lin_signals.c` `LinApp_DecodeCommand` `CMD_LEVEL` (rx byte C7) | **backlight dimming level received** from the bus (instrument-cluster dimmer) |
| `lin_signals.c` published signals | **button states + scroll counter** published to the column module |
| `lin*.c` diagnostic transport | LIN **node configuration / diagnostics** (NAD, read-by-identity) |
| `selftest.c` `ResetLog_Init` / `SelfTest_Task` | **reset-cause logging** + background flash CRC self-test |
| `buttons.c` `Buttons_Scan` / `Button_Debounce` | **steering-wheel button scan** (GPIO inputs, 4-sample shift-register debounce) |

## LIN signal picture

* **Publish (slave → master/column module):** button-press bitmap, scroll
  (roll) increment/decrement counter, and node status. Built by
  `signals.c` / `LinSig_BuildStatus` from the debounced inputs.
* **Subscribe (master → this node):** backlight **dimming level** and
  enable, decoded by `LinApp_DecodeCommand` (bytes 0x01C5..0x01C8) into the
  backlight / state variables.

Everything else in `README.md` (memory map, bootloader, build, coverage)
still applies; this file only corrects *what the firmware is for*.

## Hardware-variant coding (resistor on ADC ch 0x0B)

The steering-wheel variant is identified by a **coding resistor** (a voltage
divider) on **ADC channel 0x0B**.  At start-up `Adc_DetectVariant` (0xBEC7)
takes one 8-bit reading and classifies it into a window; each window maps to
a variant number and a feature bitmask `g_featureFlags` (0x0299).  A reading
outside every window sets `g_testMode` (coding fault, features disabled).

### Feature bits (`g_featureFlags`)

Verified from every gate in the code:

| Bit | Enables |
|-----|---------|
| 0x01 | extra button inputs + their LIN signals (`Buttons_Scan`, `Signals_Task`) |
| 0x02 | **steering-wheel heating** — `Heating_Init`/`Heating_Task` (NTC on ADC ch 3 with open/short detection + ramped output) and its signals |
| 0x04 | scroll/roll-wheel + backlight-dimming (`Backlight_*`/`Scan_*` in wheel_io.c) |
| 0x08 | a coding/identity bit only — gates no code path, just reported on LIN |

> The "heating" meaning of bit 0x02 is a reverse-engineering inference (no
> text strings in the image), but well grounded: the bit enables an NTC
> input with open/short detection driving a ramped output — the classic
> steering-wheel heater (element + temperature sensor) arrangement.

### Variant table

8-bit ADC, assuming **Vref = 5.0 V** (so U = code/255 × 5 V).  The coding
resistor is read as a divider; the firmware does not contain the pull-up
value (it is on the board), so the absolute ohms depend on the pull-up
`Rpu`.  The window ratio `k = code/255 = R/(R + Rpu)` is pull-up-independent;
`R@4k7` is the nominal coding resistor if `Rpu = 4.7 kΩ`
(`R = Rpu·k/(1−k)`).

| Variant | flags | ADC window | U window [V] | U centre | k (centre) | R @ Rpu=4.7k | Equipment (features) |
|--------:|:-----:|:----------:|:------------:|:--------:|:----------:|:------------:|:---------------------|
| 1  | 0x00 | 0x11–0x18 | 0.33–0.49 | 0.41 | 0.082 | ~0.42 kΩ | base buttons |
| 2  | 0x02 | 0x1D–0x25 | 0.57–0.75 | 0.65 | 0.129 | ~0.70 kΩ | base + **heating** |
| 3  | 0x01 | 0x2A–0x33 | 0.82–1.02 | 0.92 | 0.184 | ~1.06 kΩ | base + extended buttons |
| 4  | 0x03 | 0x39–0x43 | 1.12–1.33 | 1.22 | 0.243 | ~1.51 kΩ | extended buttons + **heating** |
| 7  | 0x08 | 0x6A–0x76 | 2.08–2.33 | 2.20 | 0.439 | ~3.68 kΩ | base (coding bit only) |
| 8  | 0x09 | 0x7C–0x89 | 2.43–2.71 | 2.57 | 0.514 | ~4.97 kΩ | extended buttons |
| **9** | **0x0F** | 0x8E–0x9D | 2.78–3.10 | 2.94 | 0.588 | ~6.71 kΩ | extended buttons + **heating** + scroll/backlight — **full** |
| 0x0A | 0x0C | 0xA3–0xB1 | 3.20–3.49 | 3.33 | 0.667 | ~9.40 kΩ | scroll wheel + backlight dimming |
| 0x0B | 0x0B | 0xB7–0xC8 | 3.59–3.94 | 3.76 | 0.753 | ~14.3 kΩ | extended buttons + **heating** |
| (none) | — | outside all | — | — | — | → `g_testMode` (fault) | — (coding fault) |

Equipment legend (derived from the feature bits): *base buttons* = the
always-present resistor-ladder + GPIO buttons and LIN; *extended buttons* =
bit 0x01 (extra button inputs + signals); *heating* = bit 0x02 (steering-
wheel heating: NTC + heated-element output, and its button); *scroll/
backlight* = bit 0x04 (roll/scroll wheel + adjustable backlight dimming).
Bit 0x08 is a coding/identity bit only (no extra equipment). So variant 9
(0x0F) is fully equipped, and heating is present on variants 2, 4, 9 and 0x0B.

(If the divider is the other way round — coding resistor to +5 V and the
pull-down fixed — invert: `R = Rpd·(1−k)/k`.)

### Answers

* **Highest-functionality variant: 9** (window 0x8E–0x9D, `flags = 0x0F`) —
  all four bits set: buttons + heating + scroll/backlight + coding bit.
* **Variants that support steering-wheel heating (bit 0x02): 2, 4, 9 and
  0x0B.**  Of these, variant 9 is the full-featured one (heating *and*
  scroll *and* all buttons).

## Pinout

The 44-pin LQFP package pin assignment and the ADC channel→pin usage are in
[`reference/pinout.md`](reference/pinout.md) — the variant-coding ADC is on
`PTD3` (AD1P11) = pin 32.
