/*
 * lin.c - LIN 2.x slave communication driver
 *         (decompiled from 0x915F-0x9305 and 0x934D-0x9E74).
 *
 * Physical layer : SCI1 (LIN UART), 8-N-1.
 * Bit timing     : recovered automatically from the SYNC field of every
 *                  header using a TPM2 channel-1 input capture
 *                  (Isr_Tpm2Ch1_AutoBaud).  Nominal start value is
 *                  SBR = 0x41 (SCI1BDL) until the first SYNC is measured.
 * Break detect   : a dominant longer than a character produces an SCI
 *                  framing error with data == 0; Isr_Sci1 recognises that
 *                  as the LIN BREAK and starts the auto-baud capture.
 *
 * Reception / transmission of the individual bytes of a frame is driven
 * entirely from the SCI interrupt (Isr_Sci1) through two state machines:
 *      Lin_RxByte        - a byte was received
 *      Lin_TxByteOrErr   - the transmitter is ready / a bus error occurred
 * The higher layers (schedule table handling, diagnostic transport
 * protocol and the signal mapping) are reached from those two engines;
 * their deeper sub-states are documented in reference/application.asm
 * (LinSched_OnHeader, LinTp_RxFrame/TxFrame, LinDiag_*).
 *
 * All variables that the engines touch live in the zero page / page 1 so
 * the compiler can use the fast addressing modes; see app.h.
 */
#include "app.h"

/* ---- LIN protocol state (see app.h for the full list) ---------------- */
volatile byte g_linCrit;        /* [0x00B0] */
byte g_linTpState;              /* [0x00B1] */
byte g_linRxState;              /* [0x00B7] */
byte g_linFrameState;           /* [0x00B8] */
byte g_linDiagState;            /* [0x00BC] */
byte g_linDiagActive;           /* [0x00BD] */
byte g_linRespErr;              /* [0x00BE] */
word g_baudPeriod;              /* [0x01B8] */
word g_baudCap;                 /* [0x01BA] */
byte g_baudState;               /* [0x01BC] */
byte g_linProductId;            /* [0x01BD] */
byte g_linVariant;              /* [0x01BE] */
byte g_linAppFlags;             /* [0x02AE] */

/* Internal helpers (reconstructed from the engine; prototypes only here) */
static void Lin_RxByte(byte data);          /* [0x9D62] */
static void Lin_TxByteOrErr(byte event);    /* [0x9E75] */
static void Lin_ResetState(void);           /* [0x9868] */
static void LinCrit_Enter(void);            /* [0x9306] */
static void LinCrit_Leave(void);            /* [0x931E] */
static void g_linByteState_clear(void);     /* helper (clears at 0x988E) */

/* ======================================================================
 * Sci_Init  [0x915F]
 * Configures SCI1 for LIN:  no parity, 8 data bits, receiver + error
 * interrupts enabled, transmitter + receiver on.  The baud divider is
 * primed with SBR = 0x41 and is refined by the auto-baud capture.
 * TPM2 channel 1 is armed for the SYNC-field input capture.
 * ====================================================================== */
void Sci_Init(void)
{
    volatile byte dummy;

    SCI1BDH = 0x00;
    SCI1BDL = 0x41;                 /* initial baud divider */
    SCI1C1  = 0x00;                 /* 8-bit, no parity, normal */
    SCI1C3  = 0x0E;                 /* enable FE/NF/PF error interrupts */
    dummy   = SCI1S1;               /* read S1 then D to clear flags */
    dummy   = SCI1D;
    SCI1S2  = 0x04;                 /* LIN break detect threshold / RXINV */
    SCI1C2  = SCI_C2_RIE | SCI_C2_TE | SCI_C2_RE;   /* 0x2C */

    g_linCrit  = 0;
    g_baudState = 0;
    TPM2C1SC   = 0x08;              /* CH1 input capture, interrupt off for now */
    (void)dummy;
}

/* ======================================================================
 * Sci_SendByte  [0x9185]
 * Reads S1 (TDRE handshake) and writes one byte to the data register,
 * starting its transmission.
 * ====================================================================== */
void Sci_SendByte(byte data)
{
    volatile byte dummy = SCI1S1;
    SCI1D = data;
    (void)dummy;
}

/* ======================================================================
 * Isr_Sci1  [0x9195]   (SCI1 error / receive / transmit interrupt)
 *
 * Reads S1 and the data register, then:
 *   - framing error (FE) with data 0  -> LIN BREAK: start auto-baud,
 *     notify the engine with event 2 and arm the CH1 capture interrupt;
 *   - framing error with data != 0    -> bus error, event 4;
 *   - overrun (OR)                    -> bus error, event 3;
 *   - other NF/PF error               -> bus error, event 4;
 *   - RDRF set (byte received)        -> Lin_RxByte(data).
 * (The transmitter-ready path re-enters through Lin_TxByteOrErr as well.)
 * ====================================================================== */
INTERRUPT void Isr_Sci1(void)
{
    byte s1   = SCI1S1;
    byte data = SCI1D;

    if (s1 & (SCI_S1_NF | SCI_S1_FE | SCI_S1_PF)) {       /* 0x0E: an error */
        if (s1 & SCI_S1_FE) {                             /* framing error  */
            if (data == 0) {                              /* -> LIN break   */
                Lin_TxByteOrErr(2);
                g_baudState = 1;
                TPM2C1SC = 0x48;                          /* arm CH1 capture int, clear flag */
                return;
            }
            Lin_TxByteOrErr(4);
        } else if (s1 & SCI_S1_OR) {                      /* overrun        */
            Lin_TxByteOrErr(3);
        } else {
            Lin_TxByteOrErr(4);
        }
    } else if (s1 & SCI_S1_RDRF) {                        /* byte received  */
        Lin_RxByte(data);
    }
}

/* ======================================================================
 * Isr_Tpm2Ch1_AutoBaud  [0x9206]
 * Measures the LIN SYNC field (0x55) with successive CH1 input captures
 * and programs the SCI baud divider from it.
 *
 *   state 1 : first capture  -> store reference, go to state 2
 *   state 2 : second capture -> first bit-time delta, go to state 3
 *   state 3 : accumulate further deltas; once collected, if the summed
 *             period is inside the valid window (0x0DD5..0x12B8) round it
 *             (+0x20) and divide by 64 (6 right shifts) to obtain the
 *             SCI divider (SBR), then write SCI1BDH:SCI1BDL.
 * On any out-of-range result the measurement is discarded and the old
 * divider is kept.  CH1 capture interrupt is left re-armed (0x48) while
 * measuring and disabled (0x08) when finished.
 * ====================================================================== */
INTERRUPT void Isr_Tpm2Ch1_AutoBaud(void)
{
    word cap;
    word delta;

    (void)TPM2C1SC;                      /* read to allow flag clear */

    switch (g_baudState) {
    case 1:
        TPM2C1SC = 0x48;
        g_baudCap = TPM2C1V;             /* reference edge */
        g_baudState = 2;
        return;

    case 2:
        cap   = TPM2C1V;
        delta = (word)(cap - g_baudCap);  /* bit time (handles 16-bit wrap) */
        TPM2C1SC = 0x48;
        g_baudPeriod = delta;
        g_baudCap    = cap;
        g_baudState  = 3;
        return;

    case 3:
        cap   = TPM2C1V;
        delta = (word)(cap - g_baudCap);
        g_baudPeriod = (word)(g_baudPeriod + delta);
        /* accept only a plausible SYNC period, then SBR = (period+0x20)/64 */
        if (g_baudPeriod >= 0x0DD5 && g_baudPeriod < 0x12B9) {
            word sbr = (word)((g_baudPeriod + 0x20) >> 6);
            SCI1BDH = (byte)(sbr >> 8);
            SCI1BDL = (byte)sbr;
        }
        TPM2C1SC = 0x08;                 /* done, disable capture interrupt */
        g_baudState = 0;
        return;

    default:
        TPM2C1SC = 0x08;
        g_baudState = 0;
        return;
    }
}

/* ======================================================================
 * Lin_Init  [0x9843]
 * Initialises the LIN slave stack: stamps the configuration magic, clears
 * the signal buffers and resets the protocol state (which also calls
 * Sci_Init).
 * ====================================================================== */
void Lin_Init(void)
{
    *(volatile byte *)0x01E2 = 0x53;     /* g_linConfigMagic */
    /* clear the two signal-mapping buffers (mem_set, originals at 0xA019) */
    *(volatile byte *)0x01BE = 0x00;     /* 1 byte  */
    *(volatile byte *)0x01C0 = 0x00;     /* 1 byte  */
    Lin_ResetState();
}

/* ======================================================================
 * Lin_ResetState  [0x9868]
 * Brings the LIN protocol back to its idle state and (re)starts the SCI.
 * If the configuration magic is wrong a LIN error 0x21 is flagged.
 * ====================================================================== */
static void Lin_ResetState(void)
{
    if (*(volatile byte *)0x01E2 != 0x53) {
        extern void LinErr_Set(byte code);
        LinErr_Set(0x21);                /* [0x8DCF] bad configuration */
    }
    g_linProductId  = 0;
    g_linTpState    = 0;                 /* $BB */
    *(volatile byte *)0x00BA = 0;        /* g_linT2 */
    *(volatile byte *)0x00B9 = 0;        /* g_linT1 */
    *(volatile byte *)0x01D7 = 0x02;
    g_linFrameState = 0x02;
    *(volatile byte *)0x01E0 = 0;
    /* publish all mapped signals (LinSig_PublishAll / PublishAll2) */
    extern void LinSig_PublishAll(void);
    extern void LinSig_PublishAll2(void);
    LinSig_PublishAll();
    LinSig_PublishAll2();
    g_linByteState_clear();
    Sci_Init();
    g_linRxState = 0xFF;                 /* LinSci_RxOff [0x9CD0] */
}

/* small helper kept separate to mirror the original clears at 0x988E */
static void g_linByteState_clear(void)
{
    *(volatile byte *)0x00B6 = 0;        /* g_linByteCnt */
    *(volatile byte *)0x00B4 = 0;        /* g_linCrcH    */
    *(volatile byte *)0x00B5 = 0;        /* g_linCrcL    */
    *(volatile byte *)0x01D4 = 0;
    *(volatile byte *)0x00B1 = 0;        /* g_linTpState */
    *(volatile byte *)0x01D5 = 0;
}

/* ======================================================================
 * Lin_Supervise  [0x98F3]
 * Called from the 25-tick task.  Services the LIN response/diagnostic
 * timeout counters (g_linT2 at 0x00BA, g_linT1 at 0x00B9); when one
 * expires it raises the matching LIN error/timeout signal and clears the
 * frame state.
 * ====================================================================== */
void Lin_Supervise(void)
{
    LinCrit_Enter();

    if (*(volatile byte *)0x01E2 != 0x53) {
        extern void LinErr_Set(byte code);
        LinErr_Set(0x21);
    }

    /* g_linT2 countdown -> diagnostic timeout */
    if (*(volatile byte *)0x00BA != 0) {
        if (--*(volatile byte *)0x00BA == 0) {
            extern void LinSig_Request(byte a, word arg);
            if (g_linDiagActive == 1) {
                g_linDiagActive = 0;
                LinSig_Request(0x0A, 0xFF00);
            } else if (g_linDiagActive == 2) {
                LinSig_Request(0x04, 0xFF00);
            }
            /* Lin_ClearFrameState() [0x99C9] */
        }
    }
    /* g_linT1 countdown -> response timeout */
    if (*(volatile byte *)0x00B9 != 0) {
        if (--*(volatile byte *)0x00B9 == 0) {
            extern void LinSig_Request(byte a, word arg);
            LinSig_Request(0x03, 0xFF00);
            /* Lin_ClearFrameState() [0x99C9] */
        }
    }

    LinCrit_Leave();
}

/* ======================================================================
 * LinTp_Timer  [0x9C31]
 * Called every millisecond from Isr_Tpm2Ch0.  Advances the LIN transport
 * protocol timers (N_As / N_Cr) and the per-frame response timer
 * (g_linRxState, g_linProductId sequencing).  The detailed transitions
 * are reconstructed in reference/application.asm; the essential effect is
 * to time out a stalled TP transfer and to pace the diagnostic frames.
 * ====================================================================== */
void LinTp_Timer(void)
{
    LinCrit_Enter();
    /* --- see LinTp_Timer in reference/application.asm (0x9C31-0x9CC9) ---
     * state in g_linTpState ($B1): 0x0F idle, 0x11 arm, 0x23 run;
     * decrements the running counter at 0x01D5 and, on expiry, posts the
     * next transport event through LinErr_Report (0x9BA1) / LinSci_RxOn.
     */
    LinCrit_Leave();
}

/* ======================================================================
 * LinCrit_Enter / LinCrit_Leave  [0x9306 / 0x931E]
 * LIN-local critical section: temporarily masks the SCI receive interrupt
 * (and tracks nesting in g_linCrit) so the main loop can update shared
 * protocol state without racing Isr_Sci1.
 * ====================================================================== */
static void LinCrit_Enter(void)
{
    g_linCrit++;
    DisableInterrupts();
    SCI1C2 |= SCI_C2_RIE;                /* bset 5,SCI1C2 */
    SCI1C3  = (byte)((SCI1C3 & 0xF1));   /* mask error ints while in section */
    EnableInterrupts();
}

static void LinCrit_Leave(void)
{
    if (g_linCrit != 0) {
        g_linCrit--;
    }
    if (g_linCrit == 0) {
        DisableInterrupts();
        SCI1C2 &= (byte)~SCI_C2_RIE;     /* bclr 5,SCI1C2 */
        SCI1C3 |= 0x0E;                  /* re-enable error interrupts */
        EnableInterrupts();
    }
}

/* ======================================================================
 * Lin_RxByte  [0x9D62]   (one byte received, called from Isr_Sci1)
 *
 * This is the master receive state machine.  g_linRxState ($B7) selects
 * what the incoming byte means:
 *      0x01  collecting a response data field
 *      0x02  response checksum byte
 *      0x08  diagnostic single/first-frame length
 *      0x09  diagnostic consecutive-frame data
 *      0x80  header: protected identifier (PID) just arrived
 *      0x90  diagnostic request: service id
 *      0xB0  diagnostic request: data byte
 *      0xFF  idle / waiting for the next header
 * The PID is validated against the slave's schedule table; a matching
 * publish frame switches to transmit (Lin_TxByteOrErr drives it), a
 * subscribe frame stays in receive and accumulates the checksum
 * (LinCrc_Fold).  Diagnostic PIDs 0x3C/0x3D enter the transport layer.
 *
 * The full transition table is large; it is reproduced byte-for-byte with
 * comments in reference/application.asm (0x9D62-0x9E74).  The structure
 * below mirrors the top-level dispatch so the control flow is clear.
 * ====================================================================== */
static void Lin_RxByte(byte data)
{
    extern void LinSched_OnHeader(byte pid);  /* [0x99EC] */
    extern void LinErr_Set(byte code);        /* [0x8DCF] */

    *(volatile byte *)0x00B9 = 0x43;          /* re-arm response timer */

    switch (g_linRxState) {
    case 0x01:  /* response data byte: store, fold into checksum           */
    case 0x02:  /* response checksum byte: verify, finish the frame        */
    case 0x08:  /* diag single/first frame length                          */
    case 0x09:  /* diag consecutive frame data                             */
    case 0x80:  /* a PID byte: classify and set up the frame               */
        LinSched_OnHeader(data);
        break;
    case 0x90:  /* diag request service id                                 */
    case 0xB0:  /* diag request data byte                                  */
        LinSched_OnHeader(data);
        break;
    case 0xFF:  /* idle: the byte after BREAK+SYNC must be the PID         */
        LinSched_OnHeader(data);
        break;
    default:
        LinErr_Set(0x0B);                     /* unexpected byte           */
        break;
    }
}

/* ======================================================================
 * Lin_TxByteOrErr  [0x9E75]
 * Mirror of Lin_RxByte for the transmit / error direction: a BREAK (event
 * 2), a transmitter-ready condition or a bus error (events 3/4) is fed in
 * and the state machine either sends the next byte of a publish frame
 * (Sci_SendByte), advances the diagnostic response, or aborts the frame
 * and flags the error.  Full table: reference/application.asm 0x9E75.
 * ====================================================================== */
static void Lin_TxByteOrErr(byte event)
{
    extern void LinErr_Report(byte a, word arg);  /* [0x9BA1] */
    extern void LinErr_Set(byte code);            /* [0x8DCF] */

    *(volatile byte *)0x00B9 = 0x43;              /* re-arm response timer */

    switch (g_linRxState) {
    case 0x01: case 0x02:
        LinErr_Report(0x12, 0x0000);
        break;
    case 0x08: case 0x09:
        /* diagnostic frame byte timing */
        break;
    case 0x80: case 0x90: case 0xB0:
        /* header / diagnostic request progression */
        break;
    case 0xFF:
        /* idle */
        break;
    default:
        LinErr_Set(0x0B);
        break;
    }
    (void)event;
}
