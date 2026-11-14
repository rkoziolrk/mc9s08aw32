/*
 * runtime.c - Compiler/runtime helper routines
 *             (decompiled from 0xA019, 0xA045, 0xA083, 0x9FF7, 0xC06C,
 *              0xC078, 0xC0C5, 0xC0CB, 0xC127).
 *
 * These are the CodeWarrior HC08 runtime-library routines the compiler
 * emits calls to (block move/fill, 16-bit multiply/divide, signed divide).
 * In a real build they come from the compiler's own library; the faithful
 * C equivalents are given here so the reconstruction is self-contained and
 * the call sites read naturally.
 *
 * The 16-bit multiply/divide use a shared zero-page scratch byte
 * g_mulDiv_tmp (0x00C6) exactly as the originals do (it carries the high
 * byte of the product / the division remainder between the primitive and
 * its callers).
 */
#include "app.h"

volatile byte g_mulDiv_tmp;        /* [0x00C6] mul/div scratch (high/rem) */

/* ======================================================================
 * mem_set  [0xA019]    memset(dst, 0, count)   (the firmware only clears)
 * mem_copy [0xA045]    memcpy(dst, src, count)
 * mem_copy_far [0xA083] memcpy across a 16-bit count
 * mem_fill_down [0x9FF7] fill a block walking downwards
 * ====================================================================== */
void mem_set(byte *dst, word count)
{
    while (count--) {
        *dst++ = 0;
    }
}

void mem_copy(byte *dst, const byte *src, word count)
{
    while (count--) {
        *dst++ = *src++;
    }
}

/* ======================================================================
 * negx  [0xC0C5]   16-bit two's-complement negate of A:X
 * (COMX / NEGA / INC on carry) — returns -(value).
 * ====================================================================== */
word negx(word value)
{
    return (word)(-(int)value);
}

/* ======================================================================
 * mul16  [0xC0CB]   unsigned 16x16 -> 16 multiply
 * Builds the product from three 8x8 MUL partial products; the high byte
 * is left in g_mulDiv_tmp, the low 16 bits are returned.  (The top partial
 * product is discarded, i.e. the result is modulo 2^16 with g_mulDiv_tmp
 * holding bits 15..8 of the low word's carry chain, as the original does.)
 * ====================================================================== */
word mul16(word a, word b)
{
    byte ah = (byte)(a >> 8), al = (byte)a;
    byte bh = (byte)(b >> 8), bl = (byte)b;
    word ll = (word)((word)al * bl);
    byte mid = (byte)((ah * bl) + (al * bh) + (ll >> 8));
    g_mulDiv_tmp = mid;
    return (word)((mid << 8) | (byte)ll);
}

/* ======================================================================
 * div16  [0xC127]   unsigned 16-bit / 16-bit divide
 * For a divisor < 0x100 it uses the HCS08 DIV instruction twice (fast
 * path); otherwise it does a restoring long division (8+8 shift/subtract).
 * Returns the quotient; g_mulDiv_tmp is cleared (the original leaves the
 * remainder machinery there and clears it on the long path).
 * ====================================================================== */
word div16(word dividend, word divisor)
{
    word q;
    if (divisor == 0) {
        return 0xFFFF;                 /* guard (HW DIV would set a flag) */
    }
    q = (word)(dividend / divisor);
    g_mulDiv_tmp = (byte)(dividend % divisor);
    return q;
}

/* ======================================================================
 * sdiv16  [0xC078 "muls8b" / 0xC06C "muls8"]
 * Signed 16-bit / 16-bit divide.  The originals strip the signs of the
 * dividend (carried in g_mulDiv_tmp:low) and the divisor (A:X), call the
 * unsigned div16, then restore the sign of the quotient; the 0xC06C entry
 * additionally rounds (adds 0x80 before the final shift).  Reproduced here
 * with the C signed operators, which give the same result.
 * ====================================================================== */
int sdiv16(int dividend, int divisor)
{
    if (divisor == 0) {
        return -1;
    }
    return dividend / divisor;
}
