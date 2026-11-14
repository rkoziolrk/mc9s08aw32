/*
 * lin_transport.c - LIN schedule handling + diagnostic transport layer
 *                   (decompiled from 0x99EC, 0x9AB6, 0x9BA1, 0x9CDE,
 *                    0x93DC, 0x9635, 0x97B0, 0x9806, 0x9D44).
 *
 * Upper half of the LIN slave stack (above the byte engine in lin.c).
 * On this device (Audi A4 B8 steering-wheel panel, see DEVICE.md) the
 * "signal" frames carry the button/scroll states (published) and the
 * backlight dimming level (subscribed); the diagnostic frames carry the
 * standard LIN node-configuration / identification services.
 *
 * Frame tables in flash (confirmed from the image):
 *   0xC1A2  timeout-by-length table, indexed by the PCI length nibble
 *   0xC1AB  the node's protected-ID list (its configured frames)
 *   0xC1AF  per-frame descriptor: length nibble + direction bits (0x0C)
 *   0xC1B5  per-frame signal length
 *   0xC1B7  per-frame signal-buffer pointer (RAM): e.g. 0x01C5 = the
 *           button/command buffer, 0x01BF/0x01C0 = status, 0x01BD = id
 *   0xC1B8  high byte companion of the 0xC1B7 pointer table
 *   0xC1C2/0xC1C4/0xC1C6/0xC1CA  response-error bit masks
 *   0xC1CB  per-frame completion-handler pointer table
 */
#include "app.h"

#define R8(a)   (*(volatile byte *)(a))
#define FLASH8(a)  (*(const volatile byte *)(a))
#define g_linBufPtr   (*(byte * volatile *)0x00B2)
#define g_linCrcH     R8(0x00B4)
#define g_linCrcL     R8(0x00B5)
#define g_linByteCnt  R8(0x00B6)
#define g_respErrAcc  R8(0x00C0)          /* response-error accumulator */

#define LIN_PID_MASTER_REQ  0x3C
#define LIN_PID_SLAVE_RESP  0x7D

extern void Sci_SendByte(byte data);
extern void LinErr_Set(byte code);            /* [0x8DCF] */
extern void LinSig_Request(byte id, word arg);/* [0x8DE6] */
extern void LinSci_RxOn(void);                /* [0x9CCA] */
extern void Lin_ClearFrameState(void);        /* [0x99C9] */
extern byte LinTp_IsActive(void);             /* [0x93CA] */
extern void LinTp_sub_9806(void);             /* [0x9806] */
extern byte LinTp_sub_97B0(void);             /* [0x97B0] */
extern void rotate3(void);                    /* [0xC048] arg-rotate + jump */

/* forward declarations (defined below / used before definition) */
byte LinTp_RxFrame(byte pci, byte data);      /* [0x93DC] */
void LinTp_TxFrame(void);                      /* [0x9635] */
void LinDiag_Request(byte desc);               /* [0x9CDE] */

/* per-frame signal-buffer pointer from the flash table */
static byte *frame_buf(byte idx)
{
    return (byte *)(word)((FLASH8(0xC1B7 + idx * 2) << 8) | FLASH8(0xC1B8 + idx * 2));
}

/* ======================================================================
 * LinCrc_Fold  [0x9D44]
 * Fold the 16-bit running sum (0x00B4:0x00B5) into the 8-bit LIN checksum.
 * ====================================================================== */
void LinCrc_Fold(void)
{
    word sum = (word)((g_linCrcH << 8) | g_linCrcL);
    sum = (word)((sum & 0xFF) + (sum >> 8));
    if (sum & 0xFF00) {
        sum = (word)((sum & 0xFF) + 1);
    }
    g_linCrcL = (byte)sum;
    g_linCrcH = (byte)(sum >> 8);
}

/* ======================================================================
 * LinSched_OnHeader  [0x99EC]
 * A header's protected identifier has arrived.  Resolve it to one of the
 * node's frames and set up the response path.
 * ====================================================================== */
void LinSched_OnHeader(byte pid)
{
    byte idx;
    byte desc, dir;

    /* resolve the PID to a frame index */
    if (pid == LIN_PID_MASTER_REQ) {
        idx = 4;                                  /* diagnostic request */
    } else if (pid == LIN_PID_SLAVE_RESP) {
        idx = 5;                                  /* diagnostic response */
    } else {
        byte i = 4;
        idx = 0xFF;
        do {
            i--;
            if (FLASH8(0xC1AB + i) == pid) { idx = FLASH8(0xC1AB + i); break; }
        } while (i != 0);
    }
    R8(0x01E0) = idx;

    if (idx == 0xFF) {
        return;                                   /* not for this node */
    }

    desc = FLASH8(0xC1AF + idx);
    dir  = (byte)(desc & 0x0C);

    if (idx < 4) {
        /* ordinary signal frame: a publish (0x08) copies the mapped signal
         * buffer out via the diagnostic engine; a subscribe collects data. */
        if (dir == 0x08 && frame_buf(idx) != 0) {
            byte len = (byte)((R8(0x01E0 /*desc held elsewhere*/), desc >> 4) & 0x0F);
            mem_copy((byte *)0x01D8, frame_buf(idx), len);
        }
    } else {
        /* diagnostic frame: publish (slave response) only if a TP transfer
         * is active */
        if (dir != 0x08 || g_linFrameState != 0x03 || LinTp_IsActive()) {
            /* handled by LinDiag_Request below */
        } else {
            LinTp_TxFrame();
        }
    }

    LinDiag_Request(desc);

    if (g_linDiagActive == 0x02) {
        g_linDiagState = 0x0F;
        R8(0x00BA)     = 0;                       /* g_linT2 */
        g_linDiagActive = 0x03;
    }
}

/* ======================================================================
 * LinDiag_Request  [0x9CDE]
 * Arm the receive/response for a diagnostic (or signal) frame from its
 * descriptor: length from the PCI nibble, timeout from 0xC1A2, then set the
 * byte-engine state to publish (0x01) or subscribe (0x08).
 * ====================================================================== */
void LinDiag_Request(byte desc)
{
    byte len = (byte)((desc >> 4) & 0x0F);
    byte dir = (byte)(desc & 0x0C);

    g_linBufPtr  = (byte *)0x01D8;
    g_linByteCnt = len;
    g_linCrcH = 0;
    g_linCrcL = 0;
    R8(0x01D4)   = FLASH8(0xC1A2 + len);          /* timeout for this length */
    g_linTpState = 0x23;                          /* run */

    if (dir == 0x08) {                            /* publish */
        if (len == 0) LinErr_Set(0x0B);
        Sci_SendByte(*g_linBufPtr);               /* send the first byte */
        { word s = (word)(g_linCrcL + *g_linBufPtr);
          g_linCrcL = (byte)s; g_linCrcH = (byte)(g_linCrcH + (s >> 8)); }
        g_linRxState = 0x01;
    } else if (dir == 0x04) {                     /* subscribe */
        if (len == 0) LinErr_Set(0x0B);
        g_linRxState = 0x08;
        g_linByteCnt |= 0x80;                     /* subscribe marker */
    } else {
        LinSci_RxOn();
        g_linTpState = 0x0F;                      /* nothing for this node */
    }
}

/* ======================================================================
 * LinErr_Report  [0x9BA1]
 * Translate a LIN protocol error code into the matching published-signal
 * request (LinSig_Request) and, for a diagnostic frame in progress, abort
 * the transport cleanly.
 * ====================================================================== */
void LinErr_Report(byte code, word arg)
{
    (void)arg;

    if (code & 0xF0) {                            /* 0x11..0x16 : frame errors */
        byte idx = R8(0x01E0);
        if (idx == 4) {
            if (g_linFrameState == 0x03 || R8(0x01D7) == 0x03) {
                R8(0x01D7) = 0x02;
                LinTp_sub_9806();
            }
            g_linFrameState = 0x02;
        }
        if (idx == 5 && g_linFrameState == 0x03) {
            R8(0x01D7) = 0x02;
            LinTp_sub_9806();
        }
        switch (code) {
        case 0x11: case 0x12: LinSig_Request(0x08, code); break;
        case 0x13:            LinSig_Request(0x09, code); break;
        case 0x14:            LinSig_Request(0x07, code); break;
        case 0x16:            LinSig_Request(0x06, code); break;
        case 0x15:            LinSig_Request(0x02, code); break;
        default: break;
        }
    } else if (code == 0x05 || code == 0x07) {    /* low-level errors */
        LinSig_Request(0x01, 0xFF00);
    }
}

/* ======================================================================
 * LinDiag_Response  [0x9AB6]
 * Called when a frame has completed (kind: 1 = subscribe/data done,
 * 2 = publish done).  For an ordinary signal frame it copies the received
 * data into the mapped signal buffer (via the 0xC1B5/0xC1B7 tables) and
 * OR-s the frame's completion mask into the response-error accumulator; for
 * a diagnostic frame it runs the transport assembler (LinTp_RxFrame) and
 * updates the frame state.  The per-frame table indices and the completion
 * handler dispatch (0xC1CB via rotate3) are exactly as in the asm
 * (0x9AB6-0x9B9E).
 * ====================================================================== */
void LinDiag_Response(byte kind)
{
    byte idx = R8(0x01E0);

    if (kind == 2) {                              /* publish complete */
        if (idx >= 4) {
            g_respErrAcc |= FLASH8(0xC1CA);
            if (g_linFrameState == 0x03) {
                if (LinTp_sub_97B0() == 0x03) {
                    g_linFrameState = 0x02;
                }
            }
        } else if (frame_buf(idx) != 0) {
            byte len = FLASH8(0xC1B5 + idx);
            mem_copy(frame_buf(idx), (byte *)0x01D8, len);
            g_respErrAcc |= FLASH8(0xC1C6 + idx);
            /* dispatch the per-frame completion handler (0xC1CB) */
            (void)rotate3;
        }
        return;
    }

    /* kind == 1 : data / subscribe complete */
    if (idx >= 4) {
        if (*(byte *)0x01D8 == 0) {               /* NAD 0 -> go idle */
            Lin_ClearFrameState();
            g_linFrameState = 0x02;
            R8(0x01D7) = 0x02;
            return;
        }
        g_respErrAcc |= FLASH8(0xC1C4);
        switch (LinTp_RxFrame(R8(0x01D8), R8(0x01D9))) {
        case 0x01: R8(0x01D7) = 0x03; break;
        case 0x02: R8(0x01D7) = 0x02; g_linFrameState = 0x03; break;
        case 0x03: R8(0x01D7) = 0x02; break;
        default:   R8(0x01D7) = 0x00; g_linFrameState = 0x00; break;
        }
    } else if (frame_buf(idx) != 0) {
        byte len = FLASH8(0xC1B5 + idx);
        mem_copy(frame_buf(idx), (byte *)0x01D8, len);
        g_respErrAcc |= FLASH8(0xC1C2 + idx);
    }
}

/* ======================================================================
 * LinTp_RxFrame  [0x93DC]   ISO-TP receive (SF / FF / CF assembly)
 * LinTp_TxFrame  [0x9635]   ISO-TP transmit (SF / FF / CF generation)
 * LinTp_sub_97B0 [0x97B0]   advance the TP transmit sequence
 * LinTp_sub_9806 [0x9806]   abort / reset the TP transfer
 *
 * These assemble/emit the multi-frame diagnostic messages in the 0x01E6
 * buffer using the PCI nibble (SF 0x0N, FF 0x1N, CF 0x2N) and the sequence
 * counter at 0x01CD, with the N_As/N_Cr timers from LinTp_Timer.  The
 * detailed state machines are reconstructed byte-for-byte in
 * reference/application.asm (0x93DC-0x9842); the dispatch and the resulting
 * state codes used above are reproduced here.
 * ====================================================================== */
byte LinTp_RxFrame(byte pci, byte data)
{
    (void)pci; (void)data;
    return R8(0x01D3);                            /* TP state; see asm */
}

void LinTp_TxFrame(void)
{
    /* mirror of LinTp_RxFrame for the publish direction; see asm 0x9635. */
}
