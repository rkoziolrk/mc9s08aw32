# Bootloader SCI/LIN reflash protocol — exact frame format

Reconstructed from the command handlers at 0xF489, 0xF53F and 0xF77E–0xFABE
of `reference/bootloader.asm`. This is the wire protocol the resident
bootloader speaks on **SCI1** once it decides to stay resident (see
`bootloader_notes.md` for the reset/launch decision).

All multi-byte values are **big-endian** (high byte first), matching the
HCS08 `LDHX/STHX` order used throughout.

---

## 1. Physical layer

| Parameter | Value | Source |
|-----------|-------|--------|
| UART | SCI1, 8 data bits, no parity, 1 stop | `Boot_SciInit` 0xFBCF/0xFBEC |
| `SCI1BDH:SCI1BDL` | `0x00:0x24` (SBR = 36) | 0xFBEC |
| `SCI1C2` | `0x0C` = TE+RE, **no interrupts** (polled) | 0xFBEC |
| Clock | ICG FEI, trimmed from NVICGTRM (0xFFBE) | `Boot_ClockInit` 0xFBAD |
| Flash clock | `FCDIV = 0x37` | `Boot_Main` 0xF6DB |

The driver is interrupt-free: two software FIFOs are pumped from the main
loop — TX = 8 bytes at RAM 0x0075, RX = 24 (0x18) bytes at RAM 0x0080.

A free-running TPM2 counter provides the time base (`Boot_TimeTick`
0xFD33); the per-byte/response timeouts are counted in the tick variable
0x009A (`Boot_sub_FDFE` re-arms the link on timeout).

---

## 2. Session state (RAM)

| Addr | Meaning |
|------|---------|
| 0x0218 | current command sub-state (0 = new command) |
| 0x0219 | byte index within the current field |
| 0x021A:0x021B | address parameter (and general 2-byte scratch) |
| 0x021C | length parameter |
| 0x021A… | **frame data buffer** (responses are sent from here, data received into here) |
| 0x01A0… | staging buffer for the **downloaded RAM routine** + its data |
| 0x01F0 / 0x01F4 | result/record pointers set after a download |
| 0x0217 | read/program mode flag (cleared by `W`, set by `L`) |
| 0x009C | "a complete frame was received" flag |

Each handler is re-entered once per received byte; it advances 0x0219 and,
when a field is complete, bumps 0x0218. A handler returns **0 when the
command is finished** (the main loop then resets the parser) and non-zero
while more bytes are expected.

---

## 3. Entry handshake (unlock)

Before any command is accepted the host must send the 4-byte **knock**:

```
'P' 'R' 'E' 'H'            ; 0x50 0x52 0x45 0x48   (ROM signature @0xFE59)
```

`Boot_sub_F489` (0xF489) reads bytes with a timeout window
(`0x009A + 0x2F` ticks) and compares each against the signature at 0xFE59;
four consecutive matches unlock the monitor. `Boot_sub_F53F` (0xF53F) then
performs a CRC handshake: it sends a 2-byte CRC (`Boot_Crc`, poly EOR 0x05)
of the sync field and waits for the host's acknowledgement before the
command loop (0xF6DE) starts.

---

## 4. Command table

Built in RAM at 0x01F6 from the ROM table at **0xFE38** (3 bytes per entry:
`id, handlerHi, handlerLo`, terminated by 0x00). The command id is an ASCII
letter:

| Id | ASCII | Handler | Command |
|----|-------|---------|---------|
| 0x45 | `E` | 0xF77E | **Execute** downloaded routine |
| 0x49 | `I` | 0xF7E4 | **Identify** (device info block) |
| 0x44 | `D` | 0xF832 | **Download** routine/data (≥0x51 bytes) → 0x01A0 |
| 0x46 | `F` | 0xF8BD | **Download** large block (≥0xA1 bytes) → 0x01A0 |
| 0x51 | `Q` | 0xF948 | **Quit / no-op** (returns 1) |
| 0x52 | `R` | 0xF94C | **Read** memory |
| 0x43 | `C` | 0xF9C9 | **Check** / blank-check (0x83 = erased) |
| 0x56 | `V` | 0xFA5B | **Vectors/Version** read |
| 0x57 | `W` | 0xFAB4 | **Write mode** (clear 0x0217) + read/verify |
| 0x4C | `L` | 0xFABE | **Lock mode** (set 0x0217) + read/verify |

---

## 5. Per-command frame formats

Notation: `-> host` = bytes the bootloader sends, `<- host` = bytes it
expects to receive. Offsets are into the 0x021A frame buffer.

### `I` — Identify  (0xF7E4)
```
<- host : 'I'
-> host : 22 (0x16) bytes = device identity block (ROM 0xFE5E):
          [0]      0x82            firmware/protocol version
          [1..2]   0x00 0x00
          [3..4]   0x01 0x80       (RAM/param info)
          [5]      0x00
          [6..7]   0xF3 0xCC       app vector-redirect table base
          [8..9]   0xF3 0xCC       (same)
          [10..11] 0xFF 0xCC       CPU vector table base
          [12]     0x02
          [13..15] 0x00 0x00 0x80  app flash start (0x8000) region
          [16..19] "AW32"          part name
          [20..21] 0x00 0x00
```
(The handler first stages the 22 bytes into 0x021A via `Boot_MemCopy` and
patches in `SDIDH` from the chip, then streams them out.)

> Direction legend (verified against the SCI primitives): the handlers use
> **Boot_SciRecv** (asm "Boot_SciPutHex", 0xFCC4 — reads the RX FIFO) and
> **Boot_SciSend** (asm "Boot_SciPutc", 0xFC67 — writes the TX FIFO).
> `<- host` = bootloader **receives**; `-> host` = bootloader **sends**.

### `D` — Download routine (0xF832)  and  `F` — Download big block (0xF8BD)
```
<- host : 'D' (or 'F')
<- host : 1 length byte  L                 ; into FRAME[0] (0x021A); F reads up to 0x1A
<- host : L data bytes                      ; into 0x021B..
          when all L bytes are in and L >= (D:0x51, F:0xA1):
            Boot_MemCopy(dstSlot, &FRAME[1], L)   ; D -> 0x01A0, F -> 0x0100
            record exec address in 0x01F4 (D also 0x01F0)
-> host : (F only) 1 byte 0x5D              ; ACK
```
`D`/`F` load the **flash-programming routine and its payload into RAM**
(slot 0x01A0 for `D`, 0x0100 for `F`). They do not program flash themselves.

### `E` — Execute (0xF77E)
```
<- host : 'E'
<- host : 2-byte address parameter          ; into FRAME[0..1] (0x021A:0x021B)
          when a complete frame is present (0x009C == 1):
            jsr 0x01A0                        ; run the routine staged by 'D'
-> host : 1 byte 0x5D                         ; ACK / completion marker
```
`E` transfers control to the routine staged by `D` — this is where the
actual flash erase/program happens, inside the downloaded RAM code.

### `R` — Read memory (0xF94C)
```
<- host : 'R'
<- host : 3 bytes  { addrHi, addrLo, count } ; into FRAME[0..2] (0x021A..0x021C)
          (if addrHi==0 and a recorded address exists, that address is used)
-> host : 'count' bytes read from [addr .. addr+count-1]
```

### `C` — Check / blank-check (0xF9C9)
```
<- host : 'C'
<- host : 3 bytes  { addrHi, addrLo, count } ; into FRAME[0..2]
          each byte in the region is compared to 0x83 (erased flash)
-> host : result byte (1 = erased/blank, 0 = programmed)
```

### `V` — Vectors / version (0xFA5B)
```
<- host : 'V'
          stages: Boot_MemCopy(0x021A, 0xFFC0, 0x1A)   ; CPU vector table
                  Boot_MemCopy(0x021E, 0x8604, 0x1E)   ; app version area
-> host : 8 bytes from 0x021A                           ; vectors/version
```

### `W` — Write mode (0xFAB4)  and  `L` — Lock mode (0xFABE)
```
<- host : 'W'  -> sets 0x0217 = 0   (write/unlocked)
<- host : 'L'  -> sets 0x0217 = 1   (locked/verify)
          common body (0xFACA):
<- host : 3 bytes  { addrHi, addrLo, count } ; into FRAME[0..2]
          write mode : fill the 0x021D staging buffer with 0x83 and, for a
                       target page >= 0x8601, set the 0x55 "program" marker;
          verify mode: receive 'count' data bytes into 0x021D..
          then, if a routine is staged and a full frame is present:
            jsr 0x0100                        ; run the downloaded programmer
-> host : 1 byte 0x5D                         ; ACK
```

### `Q` — Quit / no-op (0xF948)
```
<- host : 'Q'
-> host : (none) ; handler returns immediately (done)
```

---

## 6. Typical reflash session

```
host                        bootloader
----                        ----------
"PREH"                 -->                     ; unlock knock
                       <--  (CRC handshake)    ; F53F
'I'                    -->
                       <--  22-byte ID block   ; confirm part = AW32
'D' <routine>          -->                     ; stage flash driver -> 0x01A0
'E' <addr>             -->                     ; run driver: erase+program
                       <--  0x5D               ; done for this block
   ... repeat 'D'/'E' (or 'F'/'E') per block ...
'C' <addr>             -->                     ; verify region
                       <--  result
'V'                    -->                     ; read back vectors/version
```

After reprogramming, a reset with a valid application vector at 0xF3FE
(= 0x86E0) makes `Boot_Reset` jump straight into the new application.

---

## 7. Notes

* The two SCI primitives have misleading asm labels — verified from their
  code: `Boot_SciPutHex` (0xFCC4) actually **receives** (copies bytes out of
  the RX FIFO at 0x0080 into a buffer, returns the count), and `Boot_SciPutc`
  (0xFC67) actually **sends** (copies a buffer into the TX FIFO at 0x0075).
  The reconstruction in `reflash.c` calls them `Boot_SciRecv` / `Boot_SciSend`.
* Completion convention: the main loop runs `jsr handler; dbnza`, so a
  handler returns **1 when the command is finished** and 0 while it still
  expects more bytes.
* Every handler is fully reconstructed as C in [`reflash.c`](reflash.c)
  (`Cmd_E/I/D/F/Q/R/C/V/W/L`); this document captures the field sizes and
  semantics, and `reference/bootloader.asm` remains the byte-exact source.
* The scheme is deliberately safe: because the erase/program code only ever
  exists in RAM (downloaded, CRC-checked, then `jsr 0x01A0`), a failed
  download cannot corrupt the resident bootloader.
