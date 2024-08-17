
# Rasbperry Pi OS

This is a shell for a custom bare metal operating system on the Raspberry Pi. It is intended to be run inside `qemu` on the Raspberry Pi 3 target (when this doc was written, there was no Pi 4 target).

## Tools

You first need to upgrade all your system's software:

```
pi@raspberrypi:~ $ sudo apt update && sudo apt upgrade
```


```
pi@raspberrypi:~ $ sudo apt install qemu-system-arm vim screen gcc-aarch64-linux-gnu gdb-multiarch make git
```




## The Boot Process

On most ARM systems, we use `u-boot` to load the OS. The Pi does not do that---it has a weird boot process.

1. On power up, the ARM CPU is held in reset while the GPU loads and begins executing a hard-coded bootloader. 
2. The GPU bootloader loads some firmware files (bootcode.bin) out of the first partition of the SD card. `bootcode.bin` runs on the GPU and its job is to load the Linux kernel, which is also located on the first partition of the SD card. The kernel image must be called `kernel8.img` so the GPU bootloader can identify it. The Linux kernel image has a special Raspberry Pi-specific header (see table below) that tells the GPU bootloader where it should be placed in memory.
3. After the GPU bootloader is done loading the kernel into main memory, it brings the ARM CPU out of reset, and the ARM begins running the kernel.

| Field Contents    | Field Length | Notes                                           |
|-------------------|--------------|-------------------------------------------------|
| ASM Instruction   | 32 bits      | The first two fields in the header give us      |
|-------------------|--------------| space to write two assembly instructions. These |
| ASM Instruction   | 32 bits      | are used to jump to the kernel's entry point.   |
|-------------------|--------------|-------------------------------------------------|
| Kernel Image Size | 64 bits      | Tells the bootloader size of the kernel image.  |
|-------------------|--------------|-------------------------------------------------|
| Flags             | 64 bits      | Tells endianness, page size, and physical       |
|                   |              | placement of the kernel. PiOS uses flags =      |
|                   |              | 0x0000000000000002 which gives us little endian |
|                   |              | kernel with 4kb page size aligned as close as   |
|                   |              | possible to the base of DRAM.                   |
|-------------------|--------------|-------------------------------------------------|
| Reserved          | 64 bits      | Unused                                          |
|-------------------|--------------|-------------------------------------------------|
| Reserved          | 64 bits      | Unused                                          |
|-------------------|--------------|-------------------------------------------------|
| Reserved          | 64 bits      | Unused                                          |
|-------------------|--------------|-------------------------------------------------|
| Magic Number      | 64 bits      | Set to 0x00000000644D5241 to indicate valid     |
|                   |              | kernel image.
|-------------------|--------------|-------------------------------------------------|
| Reserved          | 64 bits      | Unused                                          |
|-------------------|--------------|-------------------------------------------------|





This shell code in this repository creates `kernel8.img` that consists of a Linux kernel header at the beginning followed by our code. Even though we are not writing the Linux kernel, we still use the same header so our OS can be loaded by the Pi's bootloader. The Linux kernel header is a data structure that tells the Raspberry Pi bootloader where to load our OS image in memory and where to start executing code inside the OS image. The kernel header is located at the top of `boot.s`, and you can find a document that explains the header format [here](https://www.kernel.org/doc/Documentation/arm64/booting.txt). We use a special linker script (`kernel.ld`) to force the kernel header to be located at the beginning of our binary file.


## Features of the Makefile

The Makefile in this repo has a bunch of useful recipes that you can use:

1. `make` or `make bin` builds the kernel binary `kernel8.img` along with `kernel8.elf`. Both are binary files that contain the compiled code of our operating system. The difference is that `kernel8.img` can be loaded by the Pi bootloader, and `kernel8.elf` is in a standard format that is recognized by tools like `gdb`.
2. `make disassemble | less` disassembles the kernel binary. Useful if you need to see where functions or variables are located in memory.
3. `make debug` runs the kernel in qemu while allowing you to step through it line-by-line in gdb.
4. `make run` runs your kernel in qemu with no debugger.
5. `make clean` removes all compiled object files.

## Adding to the Shell Code

The best way to add features is to create a new source file in the `src` directory. If you create a new source file, you will need to add it to the `OBJS` list in the Makefile (starting around line 15). For example, say you create a new file called `src/neil.c`. You will need add a new line in the Makefile:


```
OBJS = \
	boot.o \
    kernel_main.o \
    neil.o \

```

Note that the new line we added to the `OBJS` list was `neil.o`, not `neil.c`. Also, you need to make sure you have an empty line after the last element of the `OBJS` list, otherwise `make` will complain.


