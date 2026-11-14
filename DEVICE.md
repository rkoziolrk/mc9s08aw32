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
