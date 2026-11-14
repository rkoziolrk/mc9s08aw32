/*
 * vectors.c - Application interrupt vector table.
 *
 * On this device the raw CPU vectors (0xFFC0-0xFFFF) belong to the
 * bootloader; the application's handlers are reached through the
 * bootloader redirect table at 0xF3CC-0xF3FF (see bootloader_notes.md).
 * This file documents that mapping and, for a standalone build of just
 * the application, provides a conventional vector table so the image can
 * also run without the bootloader.
 *
 * Vector numbers are for the MC9S08AW32.
 */
#include "app.h"

typedef void (*vector_t)(void);

/* The application handlers that are actually used (others default). */
#if defined(AW32_STANDALONE_VECTORS)
__attribute__((section(".vectors")))
const vector_t g_appVectors[] = {
    /* 0xFFCC.. lowest-address vectors first; fill unused with Isr_Default */
    Isr_Default,              /* RTI / SRTI            */
    Isr_Default,              /* IIC1                  */
    Isr_Default,              /* ADC1                  */
    Isr_Default,              /* KBI1 -> Isr_Kbi       */
    Isr_Default,              /* SCI2 TX               */
    Isr_Default,              /* SCI2 RX               */
    Isr_Default,              /* SCI2 ERR              */
    Isr_Sci1,                 /* SCI1 TX               */
    Isr_Sci1,                 /* SCI1 RX               */
    Isr_Sci1,                 /* SCI1 ERR              */
    Isr_Default,              /* SPI1                  */
    Isr_Tpm2Ch1_AutoBaud,     /* TPM2 overflow/CH1     */
    Isr_Tpm2Ch0,              /* TPM2 CH0 (time base)  */
    /* ...additional TPM1/other vectors default to Isr_Default... */
};
#endif

/*
 * Bootloader redirect table (flash 0xF3CC-0xF3FF), for reference:
 *   SCI1 (err/rx/tx) -> Isr_Sci1              (0x9195)
 *   TPM2 ovf / CH1   -> Isr_Tpm2Ch1_AutoBaud  (0x9206)
 *   TPM2 CH0         -> Isr_Tpm2Ch0           (0x89DA)
 *   KBI              -> Isr_Kbi               (0xB55B)
 *   reset            -> App_Startup           (0x86E0)
 *   all others       -> Isr_Default           (0x87D0)
 */
