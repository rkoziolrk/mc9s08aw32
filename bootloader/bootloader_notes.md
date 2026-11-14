# Bootloader (resident firmware, 0xF400 – 0xFE73)

The bootloader owns the **hardware vector table** (0xFFC0–0xFFFF): on this
image every used CPU vector from 0xFFCC upward (reset and all peripheral
interrupts) points at **0xF400**. The bootloader therefore runs first on
every reset and is the permanent resident part of the firmware; the
application at 0x86E0 is the "download target" it protects and launches.

## Reset / launch logic — `Boot_Reset` (0xF400)

```
Boot_Reset:
    lda   SRS                 ; reset status
    beq   do_boot             ; (0 -> stay in bootloader)
    and   #$80                ; POR bit
    bne   do_boot             ; cold power-on -> stay in bootloader
    ldhx  #0xF3FE             ; application indirect reset vector
    lda   ,x                  ; read the app entry word @0xF3FE
    and   1,x
    ldx   1,x
    pulh
    inca                      ; == 0xFFFF ?  (blank / no app)
    beq   do_boot             ; blank -> stay in bootloader
    jmp   ,x                  ; otherwise jump to the application (0x86E0)
do_boot:
    ldhx  #0x046F             ; set stack pointer
    txs
    ...                       ; copy initialised data from 0xFE2A table,
    ...                       ; zero BSS 0x0217..0x031C,
    jsr   Boot_Main (0xF6B1)  ; run the download protocol
```

The word at **0xF3FE = 0x86E0** is the application's entry point. The
application's own interrupt handlers are listed in the redirect table at
**0xF3CC–0xF3FF**, which the running application uses for its vectors:

| Vector (offset) | App handler | Meaning |
|-----------------|-------------|---------|
| 0xF3DC / 0xF3DE | `0x9195` | SCI1 error / receive / transmit (`Isr_Sci1`) |
| 0xF3E4          | `0x9206` | TPM2 overflow / CH1 capture (`Isr_Tpm2Ch1_AutoBaud`) |
| 0xF3E6          | `0x89DA` | TPM2 CH0 compare – 1 ms time base (`Isr_Tpm2Ch0`) |
| 0xF3E8          | `0xB55B` | KBI (`Isr_Kbi`) |
| most others     | `0x87D0` | default ISR (restarts the app) |
| 0xF3FE (reset)  | `0x86E0` | application startup (`App_Startup`) |

## Download protocol

`Boot_Main` (0xF6B1) drives a byte-oriented programming protocol over
**SCI1** (initialised by `Boot_SciInit`, 0xFBCF → 0xFBEC: SCI1BDL = 0x24,
8-N-1, TX+RX on). It receives an S-record / block style image, verifies it
(`Boot_Crc`, 0xF626), erases the application flash pages
(`Boot_FlashErase`, 0xFBAD) and programs them (`Boot_FlashProgram`,
0xF759) — both flash routines run from RAM, like the application's config
writer. Helper I/O routines:

| Addr | Name | Purpose |
|------|------|---------|
| 0xFBCF | `Boot_SciInit`  | configure IRQ/LVD and SCI1 for the link |
| 0xFC10 | `Boot_SciGetc`  | blocking receive |
| 0xFC56 | `Boot_SciPoll`  | non-blocking receive poll |
| 0xFC67 | `Boot_SciPutc`  | blocking transmit |
| 0xFCC4 | `Boot_SciPutHex`| send a byte as ASCII hex |
| 0xFD33 | `Boot_CopFeed`  | service the COP watchdog |
| 0xFD76 | `Boot_Delay`    | busy-wait |

The complete, symbol-annotated disassembly of the bootloader is in
[`../reference/bootloader.asm`](../reference/bootloader.asm). Because the
bootloader is small, security-relevant (it can reprogram the device) and
timing-critical (its flash routines execute from RAM), it is provided as
annotated assembly rather than reconstructed C — a C rebuild could not be
guaranteed to reproduce the exact RAM-resident code bytes.

## C reconstruction

A structural C reconstruction is now in [`bootloader.c`](bootloader.c): the
reset/launch logic, the resident command loop, clock/SCI init, the polled
SCI software FIFOs, the CRC and the software time base, plus documented
handlers for the reflash protocol.

Name corrections (the auto-generated labels in `../reference/bootloader.asm`
are misleading):

| asm label | address | what it really is |
|-----------|---------|-------------------|
| `Boot_FlashErase`   | 0xFBAD | ICG **clock** init (FEI, trim) |
| `Boot_FlashProgram` | 0xF759 | a byte **memcpy** (stages the download) |
| `Boot_CopFeed`      | 0xFD33 | TPM2-based **software timer** tick |
| `Boot_Delay`        | 0xFD76 | signed **±127 range test** |

Key point: the image contains **no flash-programming code** (no FSTAT/FCMD
writes). The host downloads the flash driver into RAM at 0x01A0, the
bootloader CRC-checks it and then runs it with `jsr $01A0`. The byte-exact
protocol framing stays in `../reference/bootloader.asm`.
