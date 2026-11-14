/*
 * ports.c - GPIO configuration and critical-section helpers
 *           (decompiled from 0xB415-0xB55A and 0xB7B8-0xB7D8).
 *
 * Ports_Init() reflects the exact register writes of the firmware.  The
 * port data-direction (PTxDD), pull-up enable (PTxPE), slew-rate (PTxSE)
 * and drive-strength (PTxDS) registers are programmed per the board's
 * wiring.  Some masks are applied read-modify-write on the raw addresses
 * 0x0001..0x000D (the PTxDD page) exactly as the original did.
 */
#include "app.h"

/* ======================================================================
 * Ports_Init  [0xB415]
 * Full GPIO setup for the application.  Also enables the low-voltage
 * detect (SPMSC1/2) and clears the controller-error flag at 0x026F.
 * ====================================================================== */
void Ports_Init(void)
{
    *(volatile byte *)0x026F = 0x01;      /* g_ctrlInitFlag */
    SPMSC1 = 0x1C;                        /* LVD enable, LVW                   */
    SPMSC2 = 0x01;

    /* Port A: all inputs, no special function, pull-ups off */
    PTAD  = 0x00;  PTADD = 0xFF;
    PTADD &= 0xFD;                        /* PTA1 back to input                */
    PTASE = 0xFF;  PTADS = 0x00;

    /* Port B: all inputs */
    PTBD  = 0x00;  PTBDD = 0xFF;  PTBSE = 0xFF;  PTBDS = 0x00;

    /* Port C: PTC0 output, PTC1 pull-up; rest outputs */
    PTCDD = 0xFF;
    PTCDD = (byte)((PTCDD & 0xC1) );      /* keep bits 7,6,0                   */
    PTCDD |= 0x01;
    PTCPE = 0x02;  PTCSE = 0x00;  PTCDS = 0x00;

    /* Port D: all outputs, pull-ups off */
    PTDD  = 0x00;  PTDDD = 0xFF;
    PTDDD &= 0xF0;                        /* low nibble -> inputs              */
    PTDPE = 0x00;  PTDSE = 0x00;  PTDDS = 0x00;

    /* Port E: PTE0 + PTE7 outputs (TX + NVM-activity), PTE3/5 pull-ups    */
    PTEDD |= 0x81;
    PTEDD |= 0xFD;
    PTEDD &= 0xD7;
    PTEPE = 0x28;  PTESE = 0x00;  PTEDS = 0x00;

    /* Port F: mostly outputs except PTF5 */
    PTFD  = 0x00;  PTFDD = 0xDF;
    PTFDD &= 0xDF;
    PTFPE = 0x00;  PTFSE = 0x00;  PTFDS = 0x00;

    /* Port G: PTG0..PTG3 inputs with pull-ups (coding straps) */
    PTGD  = 0x00;  PTGDD = 0xFF;
    PTGDD &= 0x90;
    PTGPE = 0x60;  PTGSE = 0x00;  PTGDS = 0x00;
}

/* [0xB529] Prepare I/O for STOP: disable a couple of outputs / drivers */
void Ports_PrepareSleep(void)
{
    PTADD &= 0xFE;
    PTEDD &= 0xFE;
    PTEDD |= 0x01;      /* note: original writes 0x0009 |= 0x01 after &=0xFE */
}

/* [0xB53F] Make all ports inputs (except the two latching outputs) */
void Ports_AllInputs(void)
{
    PTADD = 0x00;
    PTBDD = 0x00;
    PTCDD = 0x81;
    PTDDD = 0x00;
    PTEDD = 0x01;
    PTFDD = 0x00;
    PTGDD = 0x00;
}

/* [0xB519] Drive the NVM-activity pin (PTE7) low  */
void Ports_NvmPinLow(void)  { PTED &= 0x7F; }
/* [0xB521] Drive the NVM-activity pin (PTE7) high */
void Ports_NvmPinHigh(void) { PTED |= 0x80; }

/* ======================================================================
 * EnterCritical / ExitCritical  [0xB7B8 / 0xB7C5]
 * Global nestable interrupt lock.  g_criticalNesting counts the depth so
 * nested EnterCritical()/ExitCritical() pairs only re-enable interrupts
 * when the outermost pair leaves (saturated at 0x7E/0x7F).
 * ====================================================================== */
void EnterCritical(void)
{
    DisableInterrupts();
    if (g_criticalNesting < 0x7E) {
        g_criticalNesting++;
    }
}

void ExitCritical(void)
{
    if (g_criticalNesting != 0 && g_criticalNesting < 0x7F) {
        g_criticalNesting--;
    }
    if (g_criticalNesting == 0) {
        EnableInterrupts();
    }
}

/* defined here so app.h can keep it in one place */
byte g_criticalNesting;  /* [0x0108] */
