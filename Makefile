# Makefile for the decompiled MC9S08AW32 firmware.
#
# Two useful targets:
#   make check   - validate the C as well-formed C with the host gcc
#                  (uses the AW32_HOSTCHECK shim; no MCU toolchain needed).
#   make sdcc    - attempt an MCU build with SDCC (-ms08).  SDCC's s08
#                  port is limited; interrupt handlers and the RAM-resident
#                  flash routines may need adjustment for a real image.
#
# For production use, build with NXP/Freescale CodeWarrior for HC(S)08,
# which is the compiler the original firmware was built with.

APP_SRC := $(wildcard application/*.c)
BOOT_SRC := $(wildcard bootloader/*.c)
INC     := -Icommon -Iapplication

.PHONY: check sdcc clean
check:
	@for f in $(APP_SRC); do \
	  echo "checking $$f"; \
	  gcc -DAW32_HOSTCHECK $(INC) -std=c99 -fsyntax-only -Wall \
	      -Wno-unused-variable -Wno-main $$f || exit 1; \
	done
	@for f in $(BOOT_SRC); do \
	  echo "checking $$f"; \
	  gcc -DAW32_HOSTCHECK -Icommon -std=c99 -fsyntax-only -Wall \
	      -Wno-unused-variable -Wno-unused-function -Wno-int-to-pointer-cast -Wno-main $$f || exit 1; \
	done
	@echo "all sources are well-formed C"

sdcc:
	@mkdir -p build
	@for f in $(APP_SRC); do \
	  sdcc -ms08 -c $(INC) $$f -o build/ || true; \
	done

clean:
	rm -rf build
