# LIN frames — what this slave puts on the bus

Audi A4 B8 multifunction steering-wheel panel (MC9S08AW32), LIN slave.
Derived from the flash frame tables and the reconstructed LIN stack; see
`application/lin.c`, `lin_transport.c`, `lin_signals.c` and
`reference/application.asm`.

## Frame table (flash `0xC1AB`/`0xC1AF`/`0xC1B5`/`0xC1B7`)

Protected-ID list `0xC1AB` = `C1 50 F0 61`; descriptors `0xC1AF` =
`24 34 68 28 84 88` (`len<<4 | dir`, dir `0x08`=publish, `0x04`=subscribe);
buffer pointers `0xC1B7` = `01C7 01C5 01BF 01BD`.

| idx | Frame ID | PID | dir | data len | buffer | role |
|----:|:--------:|:---:|-----|:--------:|:------:|------|
| 0 | 0x01 | 0xC1 | subscribe | 2 | 0x01C7 | command (C7/C8: incl. backlight on/off) |
| 1 | 0x10 | 0x50 | subscribe | 3 | 0x01C5 | command / dimming level (C5–C7) |
| 2 | **0x30** | **0xF0** | **publish** | 6 | 0x01BF | **status / report** |
| 3 | **0x21** | **0x61** | **publish** | 2 | 0x01BD | **identification** |
| 4 | 0x3C | 0x3C | subscribe | 8 | — | diagnostic master request |
| 5 | **0x3D** | **0x7D** | **publish** | 8 | — | **diagnostic slave response (ISO-TP)** |

The slave actively transmits only on **idx 2, 3 and 5**.

---

## A. Published signal frames (slave → master)

### A1. Status / report — ID `0x30` (PID `0xF0`), 6 bytes
Built by `LinSig_BuildStatus` (0x8F6C) into `0x01BF..0x01C4`:

| byte | addr | content |
|------|------|---------|
| 0 | 0x01BF | low nibble = rolling message counter (0..0x0F); master uses it to detect a stalled node |
| 1 | 0x01C0 | status-array sequence value (`0x029F[]`) |
| 2 | 0x01C1 | button bitmap — 8 individual bits from `0x02C4/0x02C2/0x02C1/0x02BF/0x027F/0x0280/0x0281/0x0282` |
| 3 | 0x01C2 | feature-gated bits: optional buttons `0x0283/0x0284` (if `FEAT_OPT_BUTTONS`), heating status `0x02C3` (if `FEAT_HEATER`), bit7 `0x02C0.msb` |
| 4 | 0x01C3 | two nibbles from `0x02D4` (if `0x02D1==0`) and `0x02D5` — roll/scroll counter + state |
| 5 | 0x01C4 | `0x46` if heating present, else `0xFF` |

LIN protocol errors are **folded into this frame** (see section D), i.e. this
is where "response_error"-style status is reported.

#### Status-frame signal semantics (exact, from `BuildStatus` 0x900D-0x9117)

**B2 = `0x01C1` — button bitmap (all 8 bits assembled unconditionally).**
A source byte is set only when its physical control exists and is actuated,
so bits for controls a given wheel lacks simply stay 0.

| bit | source | meaning | present on base wheel |
|:---:|:------:|---------|:---------------------:|
| 0x01 | 0x02C4 | **MODE** | yes |
| 0x02 | 0x02C2 | **left roller — click** | yes |
| 0x04 | 0x02C1 | **voice (ROZP. MOWY)** | yes |
| 0x08 | 0x02BF | **right roller — click** | yes |
| 0x10 | 0x027F | extra button | only on wheels fitted with it |
| 0x20 | 0x0280 | extra button | only on wheels fitted with it |
| 0x40 | 0x0281 | extra button | only on wheels fitted with it |
| 0x80 | 0x0282 | extra button | only on wheels fitted with it |

The four lower bits + the roller clicks were confirmed on real hardware with a
PICkit LIN monitor on a base wheel (no heating, no paddles, no extra buttons);
the four upper bits never asserted there because those controls are absent.

**B3 = `0x01C2` — mixed button / status (feature-gated).**

| bit | source | meaning | condition |
|:---:|:------:|---------|-----------|
| 0x01 | 0x0283 | optional button | only if `FEAT_OPT_BUTTONS` (0x01) |
| 0x02 | 0x0284 | optional button | only if `FEAT_OPT_BUTTONS` (0x01) |
| 0x08 | 0x02C3.0 | **heating status (NOT a button)** | only if `FEAT_HEATER` (0x02) |
| 0x40 | 0x02C3.4 | **heating status (NOT a button)** | only if `FEAT_HEATER` (0x02) |
| 0x80 | 0x02C0.msb | button ("i"/NAV) | always |
| 0x04, 0x10, 0x20 | — | **never written → static** | baseline |

Because bits 2/4/5 are never touched, B3 idles at **`0x34`** (= 0x04+0x10+0x20);
the firmware even masks B3 with `and #$34` in the idle/reset state (0x8FF4).
So a decoder may treat `B3 ^ 0x34` as the live bits — valid as long as the
wheel has **no heating**, otherwise bits 0x08/0x40 carry heating status and a
naive XOR would report them as phantom button events.

**B4 = `0x01C3` — roller rotation (signed nibbles).**
Low nibble ← `0x02D4` (only when `0x02D1==0`) = left roller steps;
high nibble ← `0x02D5` = right roller steps. (Roller *rotation*; the roller
*click* is the B2 bit above.)

**B5 = `0x01C4`** = `0x46` when `FEAT_HEATER` is set, else `0xFF` — a ready-made
"is this a heated wheel" indicator (useful to auto-select the B3 decode).

### A2. Identification — ID `0x21` (PID `0x61`), 2 bytes
`0x01BD..0x01BE`, set by `LinSig_InitTx` (0x8F18):

* `0x01BD` product id — computed from the flash signature bytes `0x8603/0x8604`
  (ASCII-decoded), mixed with `g_codingByte` (strap coding) and the variant;
* `0x01BE` variant code.

---

## B. Diagnostic slave response — ID `0x3D` (PID `0x7D`), 8 bytes

Sent in reply to the master request frame **ID `0x3C`**. Implemented as the
LIN diagnostic **ISO-TP** transport (`LinTp_RxFrame` 0x93DC / `LinTp_TxFrame`
0x9635):

* **Node NAD = `0x0A`** (wildcard `0x7F` also accepted; NAD `0x00` → go idle).
* Frame forms:
  * **SF** (Single Frame) — PCI `0x0L`, response payload ≤ 6 bytes;
  * **FF** (First Frame) — PCI `0x1L`+length, then **CF** (Consecutive
    Frames) PCI `0x2N` — for longer responses.
* A classification gate (`LinLL_Classify` 0x9F6B) accepts/rejects the request
  (physical vs functional, length gate) and maintains a product-identification
  / link-layer status byte (`g_llStatus` at `0x01E6`).

**Scope note (honest):** this firmware implements the diagnostic **transport
and the accept/reject + link-layer status**, but there is **no UDS-style
per-service dispatcher** — no code builds service-specific positive responses
(e.g. Read-by-Identifier `0xB2`→`0xF2`, Assign-NAD `0xB0`→`0xF0`): a search of
the image finds no `0xF0/0xF2` response-SID construction, and the only writers
of the response buffer `0x01E6` are the transport copy and the link-layer
status byte. The response frame therefore carries back the transported payload
/ link-layer status, not computed per-SID service replies. Node identification
is exposed mainly through the published identification frame (A2).

---

## C. Received-only frames (master → slave, no bus response)

| Frame ID | PID | len | buffer | content |
|:--------:|:---:|:---:|:------:|---------|
| 0x01 | 0xC1 | 2 | 0x01C7 | command bytes C7/C8 (incl. backlight on/off `0x028F`) |
| 0x10 | 0x50 | 3 | 0x01C5 | command / dimming level C5–C7 (illumination brightness) |
| 0x3C | 0x3C | 8 | — | diagnostic master request (later triggers the 0x3D response) |

The command bytes decoded by `LinApp_DecodeCommand` (C5–C8) drive the
LIN-commanded illumination (see DEVICE.md "Illumination control").

---

## D. Error / fault signaling (not a separate frame)

`LinErr_Report` (0x9BA1) maps LIN protocol errors into published-status bits
via `LinSig_Request`:

| error code | → published signal request |
|:----------:|----------------------------|
| 0x11, 0x12 | 0x08 |
| 0x13 | 0x09 |
| 0x14 | 0x07 |
| 0x15 | 0x02 |
| 0x16 | 0x06 |
| 0x05 / 0x07 (low-level) | 0x01 (arg 0xFF00) |

So bus/response errors surface inside the **status frame (ID 0x30)**, not as a
dedicated error frame. `LinErr_Set` forces safe defaults on bad frames.

---

## Confidence

* Frame IDs / PIDs / directions / lengths / buffers — **high** (flash tables).
* Status-frame content and identification — **high** (reconstructed source +
  asm bit map `0x9000-0x9117`).
* Diagnostic channel = transport + classification, **no per-SID service
  table** — **high for the absence**, but the exact meaning of the
  link-layer status/identifier bytes was not fully enumerated.
