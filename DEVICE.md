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

> ⚠️ Naming note. The reverse-engineering symbol names were assigned before
> the device was known, so several are thematic placeholders. The code
> structure, hardware access and control flow are correct; only the *theme*
> of some names is off. This table gives the real meaning. The symbol names
> are kept as-is so the C stays cross-referenced to `reference/*.asm`.

## Re-interpretation of the modules

| File / symbol | Placeholder name | **Real function** |
|---------------|------------------|-------------------|
| `adc.c` `Adc_DetectVariant` (ch 0x0B) | "hardware variant" | **steering-wheel coding** — which button set / wheel type is fitted; selects the feature set |
| `adc.c` `Adc_Read` (ch 2) | ADC read | reads the **button resistor ladder** voltage |
| `motor_control.c` `Ctrl_*` / `Motor_Task` | controller / motor | **button decode + debounce**, map ladder level → pressed button, scroll steps |
| `motor_control.c` `MotorPos_Isr` (1 ms) | commutation ISR | **button-ladder / scroll sampling + backlight PWM update** tick |
| `motor_control.c` `MotorPos_*` 0x0241/0x0242 | position window | **button-ladder reference / threshold levels** (per-button calibration) |
| `motor_control.c` `Motor_sub_A8B6`/`A91B` (current vs feedback) | stall / over-current | **ladder plausibility / stuck-button / short detection** |
| `motor_control.c` `Motor_Ramp` (0xB667) | slew limiter | **backlight brightness fade** (and supply filtering) |
| `main.c` `Tpm1_Init` (TPM1 CH1 PWM) | motor PWM | **backlight LED PWM** (brightness) |
| `heater.c` `Heater_*` | heater | an extra analogue channel (ch 3) with open/short detect — likely a **temperature / illumination sensor or an extra wheel option**; keep as "aux analogue input" |
| `supply.c` `Supply_*` | supply monitor | **KL30 supply-voltage monitoring** (unchanged) |
| `lin_signals.c` `LinApp_DecodeCommand` `CMD_LEVEL` (rx byte C7) | command level | **backlight dimming level received** from the bus (instrument-cluster dimmer) |
| `lin_signals.c` published signals | status signals | **button states + scroll counter** published to the column module |
| `lin*.c` diagnostic transport | diag | LIN **node configuration / diagnostics** (NAD, read-by-identity) — standard for an Audi LIN slave |
| `selftest.c` reset counters | reset logging | boot/reset bookkeeping in the coding EEPROM image (unchanged) |

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
| 0x01 | extra button inputs + their LIN signals (`Fault_Task`, `Signals_Task`) |
| 0x02 | **steering-wheel heating** — `Heater_Init`/`Heater_Task` (NTC on ADC ch 3 with open/short detection + ramped output) and its signals |
| 0x04 | scroll/roll-wheel position controller + backlight-dimming FSM (`Ctrl_*`/`MotorPos_*`) |
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

| Variant | flags | ADC window | U window [V] | U centre | k (centre) | R @ Rpu=4.7k |
|--------:|:-----:|:----------:|:------------:|:--------:|:----------:|:------------:|
| 1  | 0x00 | 0x11–0x18 | 0.33–0.49 | 0.41 | 0.082 | ~0.42 kΩ |
| 2  | 0x02 | 0x1D–0x25 | 0.57–0.75 | 0.65 | 0.129 | ~0.70 kΩ |
| 3  | 0x01 | 0x2A–0x33 | 0.82–1.02 | 0.92 | 0.184 | ~1.06 kΩ |
| 4  | 0x03 | 0x39–0x43 | 1.12–1.33 | 1.22 | 0.243 | ~1.51 kΩ |
| 7  | 0x08 | 0x6A–0x76 | 2.08–2.33 | 2.20 | 0.439 | ~3.68 kΩ |
| 8  | 0x09 | 0x7C–0x89 | 2.43–2.71 | 2.57 | 0.514 | ~4.97 kΩ |
| **9** | **0x0F** | 0x8E–0x9D | 2.78–3.10 | 2.94 | 0.588 | ~6.71 kΩ |
| 0x0A | 0x0C | 0xA3–0xB1 | 3.20–3.49 | 3.33 | 0.667 | ~9.40 kΩ |
| 0x0B | 0x0B | 0xB7–0xC8 | 3.59–3.94 | 3.76 | 0.753 | ~14.3 kΩ |
| (none) | — | outside all | — | — | — | → `g_testMode` (fault) |

(If the divider is the other way round — coding resistor to +5 V and the
pull-down fixed — invert: `R = Rpd·(1−k)/k`.)

### Answers

* **Highest-functionality variant: 9** (window 0x8E–0x9D, `flags = 0x0F`) —
  all four bits set: buttons + heating + scroll/backlight + coding bit.
* **Variants that support steering-wheel heating (bit 0x02): 2, 4, 9 and
  0x0B.**  Of these, variant 9 is the full-featured one (heating *and*
  scroll *and* all buttons).
