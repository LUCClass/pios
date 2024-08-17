// AArch64 mode
 
.section ".kernel-header"

// Kernel Header
// See https://www.kernel.org/doc/Documentation/arm64/booting.txt
b _start           /* CODE0 : Executable code */
.word 0           /* CODE1 : Executable code */
.dword _start    /* text_offset : Image load offset, little endian */
.dword 0x0        /* image_size : Image load offset, little endian */
.dword 0x2        /* flags */
.dword 0x0        /* reserved */
.dword 0x0        /* reserved */
.dword 0x0        /* reserved */
.dword 0x644d5241 /* magic */
.dword 0x0        /* reserved */

// To keep this in the first portion of the binary.
.section ".text.boot"
 
// To keep this in the first portion of the binary.
.section ".text.boot"
 
// Make _start global.
.globl _start
 
// Entry point for the kernel. Registers:
// x0 -> 32 bit pointer to DTB in memory (primary core only) / 0 (secondary cores)
// x1 -> 0
// x2 -> 0
// x3 -> 0
// x4 -> 32 bit kernel entry point, _start location
_start:

    mrs x1, mpidr_el1
    and x1,x1,#3
    cbz x1, maincore

notmaincore: // CPU id > 0: stop
    wfi
    b notmaincore

maincore:
    // set stack before our code
    ldr     x5, =_start
    mov     sp, x5
 
    // clear bss
    ldr     x5, =__bss_start
    ldr     w6, =__bss_size
3:  cbz     w6, 4f
    str     xzr, [x5], #8
    sub     w6, w6, #1
    cbnz    w6, 3b
 
    // jump to C code, should not return
4:  bl      kernel_main
    // for failsafe, halt this core too
//    b 1b
