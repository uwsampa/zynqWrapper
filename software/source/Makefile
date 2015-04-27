################################################################################
# Author: Thierry Moreau: <moreau@cs.washington.edu>
################################################################################

CC = arm-xilinx-eabi-gcc
CFLAGS = -O3 -Wall -I../lib -I../lib/bsp/include/ -c
LDFLAGS = -Wl,-T -Wl,../lib/lscript.ld -L ../lib/bsp/lib
LIBS = -Wl,--start-group,-lxil,-lgcc,-lc,-lm,--end-group
SOURCES = test.c profile.c npu.c
OBJECTS = test.o profile.o npu.o
EXECUTABLE="test.elf"


# All Target
all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	@echo Building target: $@
	@echo Invoking: ARM gcc linker
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@ $(LIBS)
	@echo Finished building target: $@
	@echo ' '

%.o: %.c
	@echo Building object: $@
	@echo Invoking: ARM gcc compiler
	$(CC) $(CFLAGS) $< -o $@
	@echo Finished building object files: $@
	@echo ' '

%.o: ../lib/%.c
	@echo Building object: $@
	@echo Invoking: ARM gcc compiler
	$(CC) $(CFLAGS) $< -o $@
	@echo Finished building object files: $@
	@echo ' '

clean:
	@echo Cleaning up...
	rm -rf *.o *.elf
	@echo ' '
