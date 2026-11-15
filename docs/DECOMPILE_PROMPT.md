# Ready-to-use prompt for decompiling a similar firmware

Paste the block below at the start of a new session, attach the firmware
file, and fill in the `<...>` placeholders. It encodes the whole methodology
and the HCS08/CodeWarrior/Capstone pitfalls learned on this project so the
next decompilation does not re-derive them.

> Tip: if the new image is the same ecosystem (HCS08 / Audi LIN slave), add
> a line *"use `rkoziolrk/mc9s08aw32` as a template"* — see the variant at the
> bottom — so the agent clones this repo and reuses the register header,
> structure and conventions.

---

## Prompt

````
Zdekompiluj dołączony wsad firmware do czytelnego, komentowanego C.

## Co to jest (wypełnij, im więcej tym lepiej — oszczędza rundy)
- Plik: `<nazwa.s19/.hex/.bin>`
- MCU: `<np. Freescale/NXP MC9S08AW32, rdzeń HCS08>`
- Urządzenie / do czego służy: `<np. panel przycisków kierownicy Audi A4 B8: przyciski, rolka, podświetlenie, grzanie; slave LIN>`
  (Jeśli nie wiesz — napisz „nieznane”, ale jeśli wiesz, podaj od razu: nazwy funkcji mają być od początku zgodne z realnym urządzeniem, nie „motor/ctrl” jako placeholdery.)
- Vref ADC: `<np. 5 V>`   Magistrala: `<np. LIN>`   Repo GitHub: `<owner/repo>`

## Cel
Kompletny zestaw plików C/H odwzorowujący logikę, dostęp do sprzętu, tablice
i formaty ramek — tak, by się kompilował (kontrola składni) i był czytelny.
NIE twierdź, że rebuild jest bajt-w-bajt. Wzorcem bajtowo-dokładnym pozostaje
oryginalny wsad + oznaczony disasembler.

## Środowisko / narzędzia
- `pip install capstone` (ma tryb M680X HCS08). Python3, objdump dostępne.
- Zbuduj obraz z S19/HEX do bufora 64 KB. Ustal bazę z tablicy wektorów:
  reset = słowo pod 0xFFFE; sprawdź, gdzie wskazuje, i czy adresy rekordów
  S19 mapują się na absolutne (np. S1 addr 0x7Fxx → 0xFFxx przy bazie 0x8000).

## Pułapki (WAŻNE — zweryfikuj, nie ufaj na słowo)
- Capstone w trybie HCS08 **zamienia `bset`/`bclr`** (opcody 0x10–0x1F:
  parzysty=bset, nieparzysty=bclr) — popraw w generatorze. `brset`/`brclr`
  (0x00–0x0F) są POPRAWNE — potwierdź testem.
- CodeWarrior używa helpera „switch_jump” z tablicą skoków tuż po `jsr` —
  wykryj (poprzednie `cmp #N` daje liczbę wpisów) i podążaj za celami.
- Wektory mogą być w FLASH i przekierowywane: bootloader często jest właścicielem
  surowych wektorów i forwarduje do aplikacji przez tablicę redirect.
- Procedury flash (erase/program) często wykonują się z RAM (kopiowane tam),
  albo są w ogóle pobierane z zewnątrz do RAM i wołane `jsr` — nie szukaj
  FSTAT/FCMD tam, gdzie ich nie ma.
- Zweryfikuj kierunki I/O i konwencje: np. „putc/puthex” potrafią faktycznie
  CZYTAĆ z FIFO RX; konwencja zakończenia handlera (zwrot 0 vs 1) wynika z
  pętli dyspozytora (`jsr; dbnza`). Sprawdź to w kodzie, nie zgaduj.

## Metodyka (iteracyjnie, commit po każdym module)
1. Zdisasembluj z podstawianiem symboli; zbuduj indeks funkcji z grafu wywołań,
   tablic switch i wektorów. Zapisz pełne, oznaczone listingi do `reference/*.asm`.
2. Rozpoznaj architekturę: bootloader vs aplikacja, mapa pamięci, peryferia
   (zegar/ICG, timery/PWM, SCI/LIN, ADC, flash config).
3. Rekonstruuj moduł po module do C. Każdy plik od razu zapisuj i kontroluj
   składnię hostowym gcc przez shim `-DAW32_HOSTCHECK` (makra `AT()`, `INTERRUPT`,
   `EnableInterrupts` itd. puste na hoście). Dodaj `make check`.
4. Realne nazwy funkcji/plików od początku (po podaniu tożsamości urządzenia).
   Jeśli nazwa auto-generowana okaże się myląca — od razu popraw wszędzie
   (C, app.h, reference/*.asm, indeks, docs).
5. Najgłębsze ciała tablicowe/stanowe najpierw jako wierny szkielet C z
   odnośnikiem do konkretnych adresów w `.asm`; rozpisuj w pełni na żądanie.

## Dostarczane repo (struktura)
```
README.md            przegląd, mapa pamięci, build, coverage
DEVICE.md            co to za urządzenie, mapa modułów, kodowanie wariantów (rezystory), tabela wyposażenia
PROGRESS.md          status per-procedura + jak wznowić w nowej sesji
Makefile             `make check` = hostowa kontrola składni całego C
firmware/            oryginalny wsad
common/<mcu>.h       mapa rejestrów, maski bitów, helpery CPU (CodeWarrior + SDCC)
application/*.c,.h    moduły aplikacji
bootloader/*.c,.md    bootloader + opis protokołu (jeśli jest)
reference/*.asm       pełny oznaczony disasembler (wzorzec bajtowy)
reference/function_index.md
```

## Zasady
- Komentuj każdą funkcję: co robi + oryginalny adres `[0xXXXX]`.
- Zachowuj absolutne adresy zmiennych zero-page/RAM, które sprzęt/kod adresuje na stałe.
- Rozszyfruj kodowanie wariantów (jeśli jest): progi ADC → bity funkcji →
  wyposażenie; policz napięcia (dla podanego Vref) i rezystory (podaj wzór,
  bo pull-up jest sprzętowy).
- Commituj po każdym module z sensownym opisem; utrzymuj PROGRESS.md, żeby
  dało się wznowić po restarcie/limicie. Wszystko trzymaj w repo GitHub.
- Bądź uczciwy: co jest pełnym C, a co odnośnikiem do asm — wprost w coverage.

Zacznij od przygotowania narzędzi i `reference/*.asm`, potem rdzeń
(start/scheduler/zegar) i magistrala, i leć modułami. Pracuj samodzielnie,
pytaj tylko gdy tożsamość/wariant realnie zmienia interpretację.
````

---

## Variant: use this repo as a template

If the new firmware is the same ecosystem, append this to the prompt:

````
Użyj repo `rkoziolrk/mc9s08aw32` jako szablonu: sklonuj je, przejmij nagłówek
rejestrów (common/mc9s08aw32.h), strukturę katalogów, Makefile `make check`,
konwencje nazewnictwa i styl komentarzy. Zrób nowe repo `<owner/repo>` o tej
samej strukturze dla nowego wsadu.
````

## What cost us the most time (so you avoid it next time)

- **Device identity given mid-way** → a full rename pass (motor_* → buttons/
  backlight). Give the device identity up front.
- **Trusting Capstone mnemonics** → `bset`/`bclr` were swapped. Always spot-check
  the disassembler against a few known opcodes.
- **Assuming I/O direction from a name** → the bootloader "putc/puthex" actually
  received from the RX FIFO; verify from the code.
- **Ephemeral cloud container** → push to GitHub after every module and keep
  `PROGRESS.md` current so a restart/usage-limit never loses work.
