
DEBUG=1
ifeq ($(DEBUG), 1)
MBED_BASE=/opt/mbed-teensy-debug/build
else
MBED_BASE=/opt/mbed-teensy/build
endif
GCC_BIN = /opt/gcc-arm-none-eabi-4_9-2015q1/bin/
PROJECT = USBAudioPlayback

OBJECTS = ./main.o

SYS_OBJECTS = $(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM/board.o \
			  $(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM/cmsis_nvic.o \
			  $(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM/retarget.o \
			  $(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM/startup_MK20DX256.o \
			  $(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM/system_MK20DX256.o 

INCLUDE_PATHS = -I. \
				-I$(MBED_BASE)/mbed \
				-I$(MBED_BASE)/mbed/TARGET_TEENSY3_1 \
				-I$(MBED_BASE)/mbed/TARGET_TEENSY3_1/TARGET_Freescale \
				-I$(MBED_BASE)/mbed/TARGET_TEENSY3_1/TARGET_Freescale/TARGET_K20XX \
				-I$(MBED_BASE)/mbed/TARGET_TEENSY3_1/TARGET_Freescale/TARGET_K20XX/TARGET_TEENSY3_1 \
				-I$(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM \
				-I$(MBED_BASE)/dsp \
				-I$(MBED_BASE)/rtos \
				-I$(MBED_BASE)/rtos/TARGET_CORTEX_M \
				-I$(MBED_BASE)/usb/USBDevice \
				-I$(MBED_BASE)/usb//USBAudio \
				-I$(MBED_BASE)/usb//USBDevice \
				-I$(MBED_BASE)/usb//USBHID \
				-I$(MBED_BASE)/usb//USBMIDI \
				-I$(MBED_BASE)/usb//USBMSD \
				-I$(MBED_BASE)/usb//USBSerial

LIBRARY_PATHS =	-L$(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM \
				-L$(MBED_BASE)/dsp/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM \
				-L$(MBED_BASE)/rtos/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM \
				-L$(MBED_BASE)/usb/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM

LIBRARIES = -lmbed -ldsp -lcmsis_dsp -lrtos -lrtx -lUSBDevice

LINKER_SCRIPT = $(MBED_BASE)/mbed/TARGET_TEENSY3_1/TOOLCHAIN_GCC_ARM/MK20DX256.ld

############################################################################### 
AS      = $(GCC_BIN)arm-none-eabi-as
CC      = $(GCC_BIN)arm-none-eabi-gcc
CPP     = $(GCC_BIN)arm-none-eabi-g++
LD      = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY = $(GCC_BIN)arm-none-eabi-objcopy
OBJDUMP = $(GCC_BIN)arm-none-eabi-objdump
SIZE    = $(GCC_BIN)arm-none-eabi-size

CPU = -mcpu=cortex-m4 -mthumb
CC_FLAGS = $(CPU) -c -g -fno-common -fmessage-length=0 -Wall -Wextra -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP
CC_SYMBOLS = -DTARGET_TEENSY3_1 -DTOOLCHAIN_GCC_ARM -DTOOLCHAIN_GCC -DTARGET_K20DX256 -DTARGET_CORTEX_M -DTARGET_Freescale -DTARGET_M4 -D__MBED__=1 -DMBED_BUILD_TIMESTAMP=1446784004.95 -D__CORTEX_M4 -DARM_MATH_CM4 -DTARGET_K20XX 

LD_FLAGS = $(CPU) -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float -Wl,--wrap,main -Wl,-Map=$(PROJECT).map,--cref
LD_SYS_LIBS = -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys


ifeq ($(DEBUG), 1)
  CC_FLAGS += -DDEBUG -O0
else
  CC_FLAGS += -DNDEBUG -Os
endif

.PHONY: all clean lst size

all: $(PROJECT).bin $(PROJECT).hex size


clean:
	rm -f $(PROJECT).bin $(PROJECT).elf $(PROJECT).hex $(PROJECT).map $(PROJECT).lst $(OBJECTS) $(DEPS)


.asm.o:
	$(CC) $(CPU) -c -x assembler-with-cpp -o $@ $<
.s.o:
	$(CC) $(CPU) -c -x assembler-with-cpp -o $@ $<
.S.o:
	$(CC) $(CPU) -c -x assembler-with-cpp -o $@ $<

.c.o:
	$(CC)  $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu99   $(INCLUDE_PATHS) -o $@ $<

.cpp.o:
	$(CPP) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<



$(PROJECT).elf: $(OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(LIBRARIES) $(LD_SYS_LIBS) $(LIBRARIES) $(LD_SYS_LIBS)


$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

$(PROJECT).hex: $(PROJECT).elf
	@$(OBJCOPY) -O ihex $< $@

$(PROJECT).lst: $(PROJECT).elf
	@$(OBJDUMP) -Sdh $< > $@

lst: $(PROJECT).lst

size: $(PROJECT).elf
	$(SIZE) $(PROJECT).elf

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)


