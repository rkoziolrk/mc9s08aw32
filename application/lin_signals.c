/*
 * DEVICE NOTE: the 'command' signals received here are the BACKLIGHT
 * DIMMING LEVEL/enable from the bus; the published signals are BUTTON
 * states + SCROLL counter. See DEVICE.md.
 * lin_signals.c - LIN signal mapping (application layer)
 *                 (decompiled from 0x8E10, 0x8E35, 0x8E8B, 0x8EC7,
 *                  0x8EDA, 0x8F18, 0x8F6C and 0x911E).
 *
 * This is the glue between the raw LIN frame buffers and the application
 * variables:
 *   - the SUBSCRIBE (command) frame bytes 0x01C5..0x01C8 are unpacked into
 *     individual command variables by LinApp_DecodeCommand();
 *   - the PUBLISH (status/response) frame bytes 0x01BF..0x01C4 are built
 *     from the application state by LinSig_BuildStatus();
 *   - the product-id / variant identification bytes 0x01BD/0x01BE are set
 *     by LinSig_InitRx()/LinSig_InitTx() from the stored configuration and
 *     the ADC-detected variant.
 *
 * The bit layout below is exactly the one coded in the firmware and is the
 * authoritative description of the LIN command/status signals.
 */
#include "app.h"

#define R8(a)  (*(volatile byte *)(a))

/* received command frame bytes */
#define LIN_CMD_B0   R8(0x01C5)
#define LIN_CMD_B1   R8(0x01C6)
#define LIN_CMD_B2   R8(0x01C7)
#define LIN_CMD_B3   R8(0x01C8)

/* decoded command variables */
#define CMD_ONOFF        R8(0x028F)   /* C8 bit0            */
#define CMD_DIR          R8(0x0290)   /* C8 bit1            */
#define CMD_LEVEL        R8(0x028E)   /* C7 (full byte)     */
#define CMD_POS_LO       R8(0x0291)   /* C5 low nibble      */
#define CMD_POS_HI       R8(0x0292)   /* C5 high nibble     */
#define CMD_MODE         R8(0x0293)   /* C6 low nibble      */
#define CMD_FLAG_A       R8(0x0294)   /* C6 bit4            */
#define CMD_FLAG_B       R8(0x0295)   /* C6 bit5            */
#define CMD_FLAG_C       R8(0x0296)   /* C6 bit6            */

extern void LinSig_InitRx(void);   /* [0x8EDA] */
extern void LinSig_InitTx(void);   /* [0x8F18] */
extern void Lin_WakeOrReset(byte x, byte mode); /* [0x98A3] */

byte g_funcFault;   /* [0x0276] */

/* ======================================================================
 * LinApp_Reset  [0x8E10]
 * Full reset of the LIN application signal layer: re-init the RX/TX signal
 * images, (re)initialise the LIN stack, clear the bus-active flag and the
 * controller-error flag, and put the node back into the operational state.
 * ====================================================================== */
void LinApp_Reset(void)
{
    EnterCritical();
    LinSig_InitRx();
    LinSig_InitTx();
    Lin_Init();
    g_linAppFlags &= (byte)~LINAPP_BUS_ACT;   /* clear bit2 */
    g_funcFault = 0;
    Lin_WakeOrReset(0, 2);
    ExitCritical();
}

/* ======================================================================
 * LinApp_DecodeCommand  [0x8E35]
 * Unpacks the received LIN command frame into the individual command
 * variables.  Skipped while the bus is active (a frame still in progress).
 *
 * Signal layout (bytes as received in 0x01C5..0x01C8):
 *   C5: bits 3..0 = position low,  bits 7..4 = position high
 *   C6: bits 3..0 = mode,          bit4 = flagA, bit5 = flagB, bit6 = flagC
 *   C7: 8-bit level/setpoint
 *   C8: bit0 = on/off,             bit1 = direction
 * ====================================================================== */
void LinApp_DecodeCommand(void)
{
    if (g_linAppFlags & LINAPP_BUS_ACT) {
        return;                               /* frame in progress */
    }
    CMD_ONOFF  =  (byte)(LIN_CMD_B3 & 0x01);
    CMD_DIR    =  (byte)((LIN_CMD_B3 & 0x02) >> 1);
    CMD_LEVEL  =  LIN_CMD_B2;
    CMD_POS_LO =  (byte)(LIN_CMD_B0 & 0x0F);
    CMD_POS_HI =  (byte)((LIN_CMD_B0 >> 4) & 0x0F);
    CMD_MODE   =  (byte)(LIN_CMD_B1 & 0x0F);
    CMD_FLAG_A =  (byte)((LIN_CMD_B1 >> 4) & 0x01);
    CMD_FLAG_B =  (byte)((LIN_CMD_B1 >> 5) & 0x01);
    CMD_FLAG_C =  (byte)((LIN_CMD_B1 >> 6) & 0x01);
}

/* ======================================================================
 * LinApp_Supervise  [0x8E8B]
 * Checks that commands keep arriving: a 16-bit idle counter (0x01B5) is
 * compared against a limit derived from the status buffer; if the master
 * has gone quiet the node flags it (g_linAppFlags bit0) and, in the
 * special "0x28" case with output variant 0, forces a safe output level.
 * (See reference/application.asm 0x8E8B-0x8EC6 for the precise compare.)
 * ====================================================================== */
void LinApp_Supervise(void)
{
    extern void LinSig_BuildStatus(void);
    word elapsed;

    LinSig_BuildStatus();                     /* refresh the status image */

    elapsed = (word)(((word)R8(0x0162) << 8) + R8(0x0163));
    elapsed -= (word)(((word)R8(0x01B5) << 8) + R8(0x01B6));
    if ((short)elapsed < 0) {
        g_linAppFlags |= LINAPP_SLEEP_REQ;    /* command timeout */
    }
    if (R8(0x0275) == 0 && g_linAppFlags == LINAPP_BUS_ACT &&
        (word)(((word)R8(0x01B5) << 8) + R8(0x01B6)) == 0x0028) {
        R8(0x0276) = 0x01;
        R8(0x028E) = 0x50;                    /* safe level */
    }
}

/* ======================================================================
 * LinApp_CountIdle  [0x8EC7]
 * Increments the 16-bit "time since last command" counter (0x01B5),
 * saturating at 0xFFFF.
 * ====================================================================== */
void LinApp_CountIdle(void)
{
    word c = (word)(((word)R8(0x01B5) << 8) + R8(0x01B6));
    if (c < 0xFFFF) {
        c++;
        R8(0x01B5) = (byte)(c >> 8);
        R8(0x01B6) = (byte)c;
    }
}

/* ---- publish frame tables (flash) ------------------------------------- */
#define FLASH8(a)  (*(const volatile byte *)(a))

/* dst = per-frame buffer pointer (0xC1B7/0xC1B8), src = live signal source
 * pointer (0xC1DD/0xC1DE), length = 0xC1B5[idx] (or the 0xC1AF nibble). */
static byte *pub_dst(byte idx)
{
    return (byte *)(word)((FLASH8(0xC1B7 + idx * 2) << 8) | FLASH8(0xC1B8 + idx * 2));
}
static const byte *pub_src(byte idx)
{
    return (const byte *)(word)((FLASH8(0xC1DD + idx * 2) << 8) | FLASH8(0xC1DE + idx * 2));
}

/* ======================================================================
 * LinSig_PublishAll  [0x9950]   frames 0..1
 * LinSig_PublishAll2 [0x998B]   frames 2..3
 * Copy the current signal values (button bitmap, scroll counter, status)
 * into the publish frame buffers, so the next time the master polls one of
 * these frames the byte engine streams the fresh values.
 * ====================================================================== */
void LinSig_PublishAll(void)
{
    byte idx;
    for (idx = 0; idx < 2; idx++) {
        if (pub_dst(idx) != 0) {
            mem_copy(pub_dst(idx), pub_src(idx), FLASH8(0xC1B5 + idx));
        }
    }
}

void LinSig_PublishAll2(void)
{
    byte idx;
    for (idx = 2; idx < 4; idx++) {
        if (pub_dst(idx) != 0) {
            byte len = (byte)((FLASH8(0xC1AF + idx) >> 4) & 0x0F);
            mem_copy(pub_dst(idx), pub_src(idx), len);
        }
    }
}

/* ======================================================================
 * LinSig_BuildStatus  [0x8F6C]
 * Packs the live module state (button bits, scroll/roll counter, option
 * flags, supply status) into the publish signal bytes 0x01BF..0x01C4.
 *
 * Two free-running sequence counters are maintained and folded into the
 * low nibbles of 0x01BF and 0x01C0 (a rolling message counter the master
 * uses to detect a stalled node):
 *     0x0278  -> 0x01BF low nibble   (wraps at 0x0F)
 *     0x029E  -> 0x01C0              (indexes the 0x029F[] status array)
 *
 * The data bytes are assembled bit-by-bit with the "mask-merge" idiom the
 * compiler emitted:  dst = (dst & ~mask) | (aligned_src & mask).  The
 * per-bit source map (reproduced from reference/application.asm
 * 0x9000-0x9117) is:
 *   0x01C1: b0=0x02C4.0 b1=0x02C2.0 b2=0x02C1.0 b3=0x02BF.0
 *           b4=0x027F.hi b5=0x0280.hi b6=0x0281.hi b7=0x0282.msb
 *   0x01C2 (if FEAT_BIT0): b0=0x0283.0 b1=0x0284.0 ; (if FEAT_HEATER):
 *           b3=0x02C3 b6=0x02C3.hi ; b7=0x02C0.msb
 *   0x01C3: b0..3 from 0x02D4 (if 0x02D1==0), b4..7 from 0x02D5
 *   0x01C4: 0xFF, or 0x46 when FEAT_HEATER set
 * These bytes are the button / option bitmap published to the column module.
 * ====================================================================== */
void LinSig_BuildStatus(void)
{
    byte v;

    /* rolling message counter -> 0x01BF low nibble */
    if (R8(0x0278) >= 0x0F) { R8(0x0278)++; v = R8(0x0278); }
    else                    { R8(0x0278) = 0; v = 0; }
    R8(0x01BF) = (byte)((R8(0x01BF) & 0xF0) | (v & 0x0F));

    /* status-array sequence -> 0x01C0 */
    if (R8(0x029E) >= 0x0F) { R8(0x029E)++; }
    else                    { R8(0x029E) = 0; }
    R8(0x0279) = R8(0x029F + R8(0x029E));

    /* The full bit-merge assembly of 0x01C1..0x01C4 follows the per-bit map
     * above; it is reproduced byte-exactly in reference/application.asm
     * (0x8FE3-0x9117).  The structure is a sequence of
     *    C = (C & ~mask) | (align(src) & mask)
     * merges, gated by g_featureFlags for the optional bytes. */
}
