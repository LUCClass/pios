

CC := aarch64-linux-gnu-gcc
LD := aarch64-linux-gnu-ld
OBJDUMP := aarch64-linux-gnu-objdump
OBJCOPY := aarch64-linux-gnu-objcopy
CONFIGS := -DCONFIG_HEAP_SIZE=4096

CFLAGS := -O0 -ffreestanding -fno-pie -fno-stack-protector -g3 -mcpu=cortex-a53+nofp -Wall $(CONFIGS)


ODIR = obj
SDIR = src

OBJS = \
	boot.o \
	kernel_main.o \

# Make sure to keep a blank line here after OBJS list

OBJ = $(patsubst %,$(ODIR)/%,$(OBJS))

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c -g -o $@ $^

$(ODIR)/%.o: $(SDIR)/%.s
	$(CC) $(CFLAGS) -c -g -o $@ $^


all: bin rootfs.img

bin: obj $(OBJ)
	$(LD) obj/* -Tkernel.ld -o kernel8.img
	cp kernel8.img kernel8.elf
	$(OBJCOPY) -O binary kernel8.img
	aarch64-linux-gnu-size kernel8.elf

obj:
	mkdir -p obj

clean:
	rm -f obj/*
	rm -f rootfs.img
	rm -f rootfs.img
	rm -f kernel8.img
	rm -f kernel8.elf

debug:
	./launch_qemu.sh

run:
	qemu-system-aarch64 -machine raspi3b -kernel kernel8.img -hda rootfs.img -serial null -serial stdio -monitor none -nographic -k en-us

disassemble:
	$(OBJDUMP) -D kernel8.elf

rootfs.img:
	dd if=/dev/zero of=rootfs.img bs=1M count=16
	mkfs.fat -F16 rootfs.img
	mmd -i rootfs.img boot
	mmd -i rootfs.img boot/firmware
	mmd -i rootfs.img bin
	mmd -i rootfs.img etc

