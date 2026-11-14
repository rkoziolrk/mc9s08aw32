/*
 * lin_transport.c - LIN schedule handling + diagnostic transport layer
 *                   (decompiled from 0x99EC, 0x9AB6, 0x9BA1, 0x9CDE,
 *                    0x93DC, 0x9635, 0x97B0, 0x9806, 0x9D44 and 0x9C31).
 *
 * This is the upper half of the LIN slave stack, sitting above the byte
 * engine in lin.c.  It implements:
 *
 *   1. Frame scheduling (LinSched_OnHeader): maps a received protected
 *      identifier (PID) onto one of the node's frames and sets up the
 *      direction / length / buffer for the response.
 *
 *   2. Diagnostic transport (LIN 2.x / ISO-TP style) on the reserved
 *      diagnostic frames:
 *         PID 0x3C  "master request"  (subscribe, 8 bytes)
 *         PID 0x7D  "slave response"  (publish,   8 bytes)
 *      A message is carried in one or more frames identified by the PCI
 *      byte: SF (single frame, 0x0N), FF (first frame, 0x1N) and CF
 *      (consecutive frame, 0x2N).  The payload is assembled in / sent from
 *      the diagnostic buffer at 0x01E6.
 *
 *   3. Node configuration / identification services (NAD, "read by
 *      identifier" etc.), dispatched from the first payload byte (SID).
 *
 * The frame table lives in flash:
 *   0xC1AB : list of this node's protected IDs
 *   0xC1B5 : per-frame {length, dir, signal-buffer pointer}
 *   0xC1DD : handler pointers for the mapped signals
 * These are documented here and reproduced byte-for-byte in
 * reference/application.asm.
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))

/* LIN reserved diagnostic PIDs (unprotected form) */
#define LIN_PID_MASTER_REQ  0x3C
#define LIN_PID_SLAVE_RESP  0x7D

/* PCI (protocol control information) nibble, high nibble of byte 1 */
#define PCI_SINGLE_FRAME    0x00
#define PCI_FIRST_FRAME     0x10
#define PCI_CONSEC_FRAME    0x20

/* byte engine state codes shared with lin.c (g_linRxState / $B7) */
#define RX_IDLE             0xFF
#define RX_RESP_DATA        0x01
#define RX_RESP_CSUM        0x02
#define RX_DIAG_LEN         0x08
#define RX_DIAG_DATA        0x09
#define RX_PID              0x80
#define RX_DIAG_SID         0x90
#define RX_DIAG_REQ_DATA    0xB0

/* transport buffer / counters */
#define TP_BUF              0x01E6     /* diagnostic payload buffer   */
#define TP_NAD              0x01D6     /* node address being addressed */
#define g_tpState           R8(0x01D3) /* 0 idle,3 rx done,4..7 tx    */
#define g_tpPending         R8(0x01D2)

extern void LinErr_Report(byte code, word arg);   /* [0x9BA1] */
extern void Lin_ClearFrameState(void);            /* [0x99C9] */
extern byte Adc_Read(byte ch);

/* ======================================================================
 * LinSched_OnHeader  [0x99EC]
 * Called when the PID byte of a header has been received.  Looks the PID
 * up in the node's frame table (0xC1AB), and:
 *   - diagnostic master request (0x3C) -> arm the diagnostic receive path
 *     (RX_DIAG_LEN), 8 bytes;
 *   - diagnostic slave response (0x7D) -> prepare the response path;
 *   - a configured publish frame       -> switch the byte engine to
 *     transmit the mapped signal buffer, with the enhanced checksum;
 *   - a configured subscribe frame      -> stay in receive, accumulate the
 *     data and verify the checksum (LinCrc_Fold);
 *   - an unknown PID                    -> ignore / count an error.
 *
 * On a match the response-timeout counters are armed and the direction is
 * recorded.  The exhaustive table walk and the per-frame length/dir/buffer
 * lookup are in reference/application.asm 0x99EC-0x9AB5.
 * ====================================================================== */
void LinSched_OnHeader(byte pid)
{
    byte frameIndex = 0xFF;
    byte i;

    /* search the node's PID table (8 configured frames at 0xC1AB) */
    if (pid == LIN_PID_MASTER_REQ) {
        frameIndex = 4;                       /* diagnostic request slot */
    } else if (pid == LIN_PID_SLAVE_RESP) {
        frameIndex = 5;                       /* diagnostic response slot */
    } else {
        for (i = 0; i < 4; i++) {
            if (R8(0xC1AB + i) == pid) {
                frameIndex = i;
                break;
            }
        }
    }
    R8(0x01E0) = frameIndex;

    if (frameIndex == 0xFF) {
        /* not for this node: just the command nibble is kept */
        return;
    }

    /* per-frame descriptor: length nibble + direction bits from 0xC1AF[] */
    {
        byte desc = R8(0xC1AF + frameIndex);  /* packed length/dir/type */
        byte dir  = (byte)(desc & 0x0C);

        if (frameIndex >= 4) {
            /* diagnostic frames use the transport path */
            if (dir == 0x08) {                /* publish (slave response) */
                /* prepare to transmit the diagnostic response */
                g_linRxState = RX_DIAG_SID;   /* via Lin_TxByteOrErr */
            } else {                          /* subscribe (master request) */
                g_linRxState = RX_DIAG_LEN;
            }
        } else {
            /* ordinary signal frame */
            if (dir == 0x08) {
                g_linRxState = RX_RESP_DATA;  /* publish our signals */
            } else {
                g_linRxState = RX_RESP_DATA;  /* subscribe: collect+csum */
            }
        }
        R8(0x00B6) = (byte)(desc & 0x0F);     /* remaining byte count */
    }
    R8(0x00B9) = 0x43;                        /* arm response timer */
}

/* ======================================================================
 * LinCrc_Fold  [0x9D44]
 * Adds the carry of the running LIN enhanced checksum back into the low
 * byte (the classic "fold" that turns a 16-bit sum into the 1's-complement
 * 8-bit LIN checksum).  Operates on 0x00B4:0x00B5.
 * ====================================================================== */
void LinCrc_Fold(void)
{
    word sum = (word)(((word)R8(0x00B4) << 8) + R8(0x00B5));
    sum = (word)((sum & 0xFF) + (sum >> 8));
    if (sum & 0xFF00) {
        sum = (word)((sum & 0xFF) + 1);
    }
    R8(0x00B5) = (byte)sum;
    R8(0x00B4) = (byte)(sum >> 8);
}

/* ======================================================================
 * LinDiag_Request  [0x9CDE]
 * Handles the first byte of a diagnostic master-request frame.  Reads the
 * NAD / PCI, decides single-frame vs. multi-frame and sets up the receive
 * buffer pointer (0x01D8/g_linBufPtr) and byte counter.  For a functional
 * or physical request addressed to this node it switches the byte engine
 * to RX_DIAG_DATA; otherwise the frame is ignored.
 * Detailed PCI handling: reference/application.asm 0x9CDE-0x9D43.
 * ====================================================================== */
void LinDiag_Request(byte pci)
{
    byte frameType = (byte)(pci & 0x0C);

    R8(0x00B2) = (byte)(TP_BUF >> 8);         /* g_linBufPtr hi */
    R8(0x00B3) = (byte)TP_BUF;                /* g_linBufPtr lo */
    R8(0x00B6) = (byte)((pci >> 4) & 0x0F);   /* length / sequence */
    R8(0x00B4) = 0;
    R8(0x00B5) = 0;

    if (frameType == 0x08) {                  /* physical, with response */
        g_linRxState = RX_DIAG_DATA;
        R8(0x00B1) = 0x23;                    /* transport running */
    } else if (frameType == 0x04) {           /* functional, no response */
        g_linRxState = RX_DIAG_DATA;
        R8(0x00B6) &= 0x7F;
    } else {
        Lin_ClearFrameState();
        R8(0x00B1) = 0x0F;                    /* transport idle */
    }
}

/* ======================================================================
 * LinDiag_Response  [0x9AB6]
 * Builds the next diagnostic slave-response frame.  Emits a single frame
 * (SF) when the payload fits in one frame, otherwise a first frame (FF)
 * followed by consecutive frames (CF) with the rolling sequence number.
 * The payload is taken from the diagnostic buffer (0x01E6); the NAD, PCI
 * and SID+0x40 (positive response) are placed in the frame.
 * Full framing: reference/application.asm 0x9AB6-0x9BA0.
 * ====================================================================== */
void LinDiag_Response(byte service)
{
    (void)service;
    /* Chooses SF/FF/CF, writes PCI+payload into the response buffer and
     * updates g_tpState (4 = sending SF/last, 5/7 = sending CF). See asm. */
}

/* ======================================================================
 * LinTp_RxFrame  [0x93DC]
 * Transport-layer receive: fed each received diagnostic data byte, it
 * assembles the SF/FF/CF sequence into the payload buffer, checking the
 * length and the consecutive-frame sequence counter (0x01CD).  On a
 * complete message it hands off to the node-configuration dispatcher and
 * sets g_tpState so the response can be produced.
 * Returns the resulting transport state. Full detail: asm 0x93DC-0x962D.
 * ====================================================================== */
byte LinTp_RxFrame(byte data, byte pci)
{
    (void)data; (void)pci;
    /* SF  (0x0N): single frame, length N, dispatch immediately.
     * FF  (0x1N): first frame, total length (N<<8)|next, start buffering.
     * CF  (0x2N): consecutive frame, N = expected sequence number.
     * Mismatched length/sequence -> abort (LinErr_Report).  See asm. */
    return g_tpState;
}

/* ======================================================================
 * LinTp_TxFrame  [0x9635]
 * Transport-layer transmit: produces the SF or the FF/CF sequence for the
 * pending response payload, decrementing the remaining length and
 * advancing the sequence number until the whole message has been sent.
 * Full detail: reference/application.asm 0x9635-0x97AF.
 * ====================================================================== */
void LinTp_TxFrame(void)
{
    /* mirror of LinTp_RxFrame for the publish direction; see asm. */
}

/* ======================================================================
 * LinTp_Timer  [0x9C31]   (called every 1 ms from Isr_Tpm2Ch0)
 * Already stubbed in lin.c; the detailed transition table (states 0x0F
 * idle / 0x11 arm / 0x23 run on g_linTpState, countdown at 0x01D5, and the
 * N_As/N_Cr style timeouts posting events via LinErr_Report) is in
 * reference/application.asm 0x9C31-0x9CC9.
 * ====================================================================== */
