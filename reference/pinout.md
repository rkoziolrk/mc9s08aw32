# Pinout — MC9S08AW32, 44-pin LQFP

Package pin assignment (from the MC9S08AW datasheet 44-Pin LQFP figure) and
the ADC channels this firmware actually uses. Port→ADC mapping: AD0–AD7 =
PTB0–PTB7, AD8–AD15 = PTD0–PTD7 (only a subset is bonded out on the 44-pin
package).

## ADC usage by the firmware

| Function | `Adc_Read()` ch | Signal / port pin | 44-LQFP pin |
|----------|-----------------|-------------------|:-----------:|
| **Start-up option coding** (TCUT1350X01 common emitter) | AD11 (0x0B) | `AD1P11` / `PTD3` | **32** |
| Supply-voltage monitor / current | AD10 (0x0A) | `AD1P10` / `PTD2` | **31** |
| Heating NTC sensor | AD3 (0x03) | `AD1P3` / `PTB3` | **26** |
| Button resistor ladder / feedback | AD2 (0x02) | `AD1P2` / `PTB2` | **25** |
| ADC references | — | `VREFH` / `VREFL` | 34 / 35 |
| ADC supply | — | `VDDAD` / `VSSAD` | 29 / 30 |

Note: `PTD3` (and `PTD2`, `PTD7`, `PTG4`) carry both a pull-up and a
pull-down device.  On this board (hardware inspection) **PTD3 / pin 32 is
wired, through series resistors, to the common emitter of the TCUT1350X01**
transmissive optical sensor (the scroll-wheel encoder).  `Adc_DetectVariant`
reads this rail **once** at start-up as the option/presence code — it is not a
plain coding-resistor divider, so no resistor value is inferred here.

Note: **`PTE2` / pin 10 (TPM1CH0) is a NO-CONNECT** on this board.  The
`Output_*` self-test/stall stage toggles it and reads ADC feedback, but drives
no physical load here (vestigial/generic actuator code); it is not a
button-LED health check.

### Illumination (backlight) PWM

| Function | TPM1 channel | Port pin | 44-LQFP pin |
|----------|--------------|----------|:-----------:|
| **Backlight PWM (dimmed over LIN)** | TPM1CH2 | `PTF0` | **4** |
| Second output, fixed ~50% (only when PTC4=VDD) | TPM1CH1 | `PTE3` | **11** |
| Output-config strap → `g_outputVariant` | — | `PTC4` | **1** |

The dimmable illumination is `TPM1CH2`/`PTF0` (pin 4): `TPM1MOD = 0xC8`, duty
`TPM1C2V = 0xC8 − f(0x02B4)` where `0x02B4` is set from the cyclic LIN command
(`LinApp_DecodeCommand` → `0x028F`).  No LIN traffic → duty `0xC8` → full
brightness.  **`PTC4` / pin 1** is read at runtime (`brclr 4,PTCD`): at VDD it
sets `g_outputVariant = 1`, which additionally enables the fixed ~50% output on
`PTE3` / pin 11 (on the inspected board PTC4 = VDD).  See DEVICE.md
"Illumination (backlight) control".

## Full 44-LQFP pin list

| Pin | Signal(s) | Pin | Signal(s) |
|----:|-----------|----:|-----------|
| 1  | PTC4 | 23 | PTB0 / AD1P0 |
| 2  | IRQ | 24 | PTB1 / AD1P1 |
| 3  | RESET | 25 | PTB2 / AD1P2 |
| 4  | PTF0 / TPM1CH2 | 26 | PTB3 / AD1P3 |
| 5  | PTF1 / TPM1CH3 | 27 | PTD0 / AD1P8 |
| 6  | PTF4 / TPM2CH0 | 28 | PTD1 / AD1P9 |
| 7  | PTF5 / TPM2CH1 | 29 | VDDAD |
| 8  | PTE0 / TxD1 | 30 | VSSAD |
| 9  | PTE1 / RxD1 | 31 | PTD2 / KBI1P5 / AD1P10 |
| 10 | PTE2 / TPM1CH0 | 32 | PTD3 / KBI1P6 / AD1P11 |
| 11 | PTE3 / TPM1CH1 | 33 | PTG3 / KBI1P3 |
| 12 | PTE4 / SS1 | 34 | VREFH |
| 13 | PTE5 / MISO1 | 35 | VREFL |
| 14 | PTE6 / MOSI1 | 36 | BKGD / MS |
| 15 | PTE7 / SPSCK1 | 37 | PTG5 / XTAL |
| 16 | VSS | 38 | PTG6 / EXTAL |
| 17 | VDD | 39 | VSS |
| 18 | PTG0 / KBI1P0 | 40 | PTC0 / SCL1 |
| 19 | PTG1 / KBI1P1 | 41 | PTC1 / SDA1 |
| 20 | PTG2 / KBI1P2 | 42 | PTC2 / MCLK |
| 21 | PTA0 | 43 | PTC3 / TxD2 |
| 22 | PTA1 | 44 | PTC5 / RxD2 |

LIN uses **PTE0/TxD1** (pin 8) and **PTE1/RxD1** (pin 9) — the SCI1 driver.
