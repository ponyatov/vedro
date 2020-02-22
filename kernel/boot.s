; https://github.com/qemu/qemu/tree/master/tests/multiboot
; https://github.com/qemu/qemu/blob/master/tests/multiboot/start.S

.section .boot

#define MB_MAGIC 0x1badb002
#define MB_FLAGS 0x0
#define MB_CHECKSUM -(MB_MAGIC + MB_FLAGS)

.align  4
.int    0x1badb002
.int    0x0
.int    -(0x1badb002 + 0x0)

.section .text
.global _start
_start:
    mov     $stack, %esp
    push    %ebx
    push    %eax

    call    init

    /* Test device exit */
    outl    %eax, $0xf4

    cli
    hlt
    jmp .

.section .bss
.space 0x200
stack:

