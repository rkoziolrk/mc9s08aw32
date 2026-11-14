/*
 * mc9s08aw32.h - Minimal register map of the Freescale/NXP MC9S08AW32 (HCS08)
 *
 * Written for the decompiled firmware.  Only the peripheral registers are
 * declared (as volatile byte/word lvalues at their absolute addresses), plus
 * the bit masks that the firmware actually uses.  It can be used with
 * CodeWarrior for HC08 or with SDCC (-ms08).
 *
 * Memory map (MC9S08AW32):
 *   0x0000-0x006F  direct page peripheral registers
 *   0x0070-0x086F  RAM (2 KB)
 *   0x1800-0x185F  high page registers
 *   0x8000-0xFFFF  FLASH (32 KB), 512-byte erase pages
 *   0xFFB0-0xFFBF  NV registers (backdoor key, NVPROT, NVICGTRM, NVOPT)
 *   0xFFC0-0xFFFF  interrupt vectors
 */
#ifndef MC9S08AW32_H
#define MC9S08AW32_H

typedef unsigned char  byte;
typedef unsigned int   word;     /* 16-bit on HCS08 compilers */
typedef unsigned long  dword;

#define REG8(a)   (*(volatile byte *)(a))
#define REG16(a)  (*(volatile word *)(a))   /* big-endian, high byte first */

#define PTAD       REG8(0x0000)
#define PTADD      REG8(0x0001)
#define PTBD       REG8(0x0002)
#define PTBDD      REG8(0x0003)
#define PTCD       REG8(0x0004)
#define PTCDD      REG8(0x0005)
#define PTDD       REG8(0x0006)
#define PTDDD      REG8(0x0007)
#define PTED       REG8(0x0008)
#define PTEDD      REG8(0x0009)
#define PTFD       REG8(0x000A)
#define PTFDD      REG8(0x000B)
#define PTGD       REG8(0x000C)
#define PTGDD      REG8(0x000D)
#define ADC1SC1    REG8(0x0010)
#define ADC1SC2    REG8(0x0011)
#define ADC1RH     REG8(0x0012)
#define ADC1RL     REG8(0x0013)
#define ADC1CVH    REG8(0x0014)
#define ADC1CVL    REG8(0x0015)
#define ADC1CFG    REG8(0x0016)
#define APCTL1     REG8(0x0017)
#define APCTL2     REG8(0x0018)
#define APCTL3     REG8(0x0019)
#define IRQSC      REG8(0x001C)
#define KBI1SC     REG8(0x001E)
#define KBI1PE     REG8(0x001F)
#define TPM1SC     REG8(0x0020)
#define TPM1CNTH   REG8(0x0021)
#define TPM1CNTL   REG8(0x0022)
#define TPM1MODH   REG8(0x0023)
#define TPM1MODL   REG8(0x0024)
#define TPM1C0SC   REG8(0x0025)
#define TPM1C0VH   REG8(0x0026)
#define TPM1C0VL   REG8(0x0027)
#define TPM1C1SC   REG8(0x0028)
#define TPM1C1VH   REG8(0x0029)
#define TPM1C1VL   REG8(0x002A)
#define TPM1C2SC   REG8(0x002B)
#define TPM1C2VH   REG8(0x002C)
#define TPM1C2VL   REG8(0x002D)
#define TPM1C3SC   REG8(0x002E)
#define TPM1C3VH   REG8(0x002F)
#define TPM1C3VL   REG8(0x0030)
#define TPM1C4SC   REG8(0x0031)
#define TPM1C4VH   REG8(0x0032)
#define TPM1C4VL   REG8(0x0033)
#define TPM1C5SC   REG8(0x0034)
#define TPM1C5VH   REG8(0x0035)
#define TPM1C5VL   REG8(0x0036)
#define SCI1BDH    REG8(0x0038)
#define SCI1BDL    REG8(0x0039)
#define SCI1C1     REG8(0x003A)
#define SCI1C2     REG8(0x003B)
#define SCI1S1     REG8(0x003C)
#define SCI1S2     REG8(0x003D)
#define SCI1C3     REG8(0x003E)
#define SCI1D      REG8(0x003F)
#define SCI2BDH    REG8(0x0040)
#define SCI2BDL    REG8(0x0041)
#define SCI2C1     REG8(0x0042)
#define SCI2C2     REG8(0x0043)
#define SCI2S1     REG8(0x0044)
#define SCI2S2     REG8(0x0045)
#define SCI2C3     REG8(0x0046)
#define SCI2D      REG8(0x0047)
#define ICGC1      REG8(0x0048)
#define ICGC2      REG8(0x0049)
#define ICGS1      REG8(0x004A)
#define ICGS2      REG8(0x004B)
#define ICGFLTU    REG8(0x004C)
#define ICGFLTL    REG8(0x004D)
#define ICGTRM     REG8(0x004E)
#define SPI1C1     REG8(0x0050)
#define SPI1C2     REG8(0x0051)
#define SPI1BR     REG8(0x0052)
#define SPI1S      REG8(0x0053)
#define SPI1D      REG8(0x0055)
#define IIC1A      REG8(0x0058)
#define IIC1F      REG8(0x0059)
#define IIC1C      REG8(0x005A)
#define IIC1S      REG8(0x005B)
#define IIC1D      REG8(0x005C)
#define TPM2SC     REG8(0x0060)
#define TPM2CNTH   REG8(0x0061)
#define TPM2CNTL   REG8(0x0062)
#define TPM2MODH   REG8(0x0063)
#define TPM2MODL   REG8(0x0064)
#define TPM2C0SC   REG8(0x0065)
#define TPM2C0VH   REG8(0x0066)
#define TPM2C0VL   REG8(0x0067)
#define TPM2C1SC   REG8(0x0068)
#define TPM2C1VH   REG8(0x0069)
#define TPM2C1VL   REG8(0x006A)
#define SRS        REG8(0x1800)
#define SBDFR      REG8(0x1801)
#define SOPT       REG8(0x1802)
#define SDIDH      REG8(0x1806)
#define SDIDL      REG8(0x1807)
#define SRTISC     REG8(0x1808)
#define SPMSC1     REG8(0x1809)
#define SPMSC2     REG8(0x180A)
#define FCDIV      REG8(0x1820)
#define FOPT       REG8(0x1821)
#define FCNFG      REG8(0x1823)
#define FPROT      REG8(0x1824)
#define FSTAT      REG8(0x1825)
#define FCMD       REG8(0x1826)
#define PTAPE      REG8(0x1840)
#define PTASE      REG8(0x1841)
#define PTADS      REG8(0x1842)
#define PTBPE      REG8(0x1844)
#define PTBSE      REG8(0x1845)
#define PTBDS      REG8(0x1846)
#define PTCPE      REG8(0x1848)
#define PTCSE      REG8(0x1849)
#define PTCDS      REG8(0x184A)
#define PTDPE      REG8(0x184C)
#define PTDSE      REG8(0x184D)
#define PTDDS      REG8(0x184E)
#define PTEPE      REG8(0x1850)
#define PTESE      REG8(0x1851)
#define PTEDS      REG8(0x1852)
#define PTFPE      REG8(0x1854)
#define PTFSE      REG8(0x1855)
#define PTFDS      REG8(0x1856)
#define PTGPE      REG8(0x1858)
#define PTGSE      REG8(0x1859)
#define PTGDS      REG8(0x185A)

/* 16-bit views of the timer registers (reading the high byte latches the low) */
#define TPM1CNT    REG16(0x0021)
#define TPM1MOD    REG16(0x0023)
#define TPM1C0V    REG16(0x0026)
#define TPM1C1V    REG16(0x0029)
#define TPM1C2V    REG16(0x002C)
#define TPM1C3V    REG16(0x002F)
#define TPM2CNT    REG16(0x0061)
#define TPM2MOD    REG16(0x0063)
#define TPM2C0V    REG16(0x0066)
#define TPM2C1V    REG16(0x0069)
#define ADC1R      REG16(0x0012)

/* NV area programmed with the firmware */
#define NVICGTRM   (*(const volatile byte *)0xFFBE)   /* factory/ user ICG trim value */

/* ---- bit masks used by the firmware ---- */
#define SRS_POR        0x80
#define ICGS1_LOCK     0x08
#define ICGS2_DCOS     0x01
#define SCI_S1_TDRE    0x80
#define SCI_S1_TC      0x40
#define SCI_S1_RDRF    0x20
#define SCI_S1_IDLE    0x10
#define SCI_S1_OR      0x08
#define SCI_S1_NF      0x04
#define SCI_S1_FE      0x02
#define SCI_S1_PF      0x01
#define SCI_C2_TIE     0x80
#define SCI_C2_TCIE    0x40
#define SCI_C2_RIE     0x20
#define SCI_C2_TE      0x08
#define SCI_C2_RE      0x04
#define FSTAT_FCBEF    0x80
#define FSTAT_FCCF     0x40
#define FSTAT_FPVIOL   0x20
#define FSTAT_FACCERR  0x10
#define FCMD_BYTE_PROG 0x20
#define FCMD_BURST     0x25
#define FCMD_PAGE_ERASE 0x40
#define ADC_SC1_COCO   0x80
#define TPM_SC_TOF     0x80
#define TPM_CSC_CHF    0x80

/* ---- CPU helpers ---- */
#if defined(AW32_HOSTCHECK)
  #define EnableInterrupts()  ((void)0)
  #define DisableInterrupts() ((void)0)
  #define STOP()  ((void)0)
  #define NOP()   ((void)0)
  #define INTERRUPT
#elif defined(__SDCC)
  #define EnableInterrupts()   __asm__("cli")
  #define DisableInterrupts()  __asm__("sei")
  #define STOP()               __asm__("stop")
  #define NOP()                __asm__("nop")
  #define INTERRUPT            __interrupt
#else   /* CodeWarrior HC08 */
  #define EnableInterrupts()   __asm CLI
  #define DisableInterrupts()  __asm SEI
  #define STOP()               __asm STOP
  #define NOP()                __asm NOP
  #define INTERRUPT            interrupt
#endif

/* COP (watchdog) service: write 0x55 then 0xAA to SRS */
#define COP_FEED()  do { SRS = 0x55; SRS = 0xAA; } while (0)

#endif /* MC9S08AW32_H */
