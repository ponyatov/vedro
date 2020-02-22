/* https://github.com/qemu/qemu/blob/master/tests/multiboot/link.ld */

ENTRY(_start)

SECTIONS {
    . = 0x100000;
    _start = .;
    .text       ALIGN(4096) : { *(.boot) *(.text)   }
    .data       ALIGN(4096) : { *(.data)            }
    .rodata     ALIGN(4096) : { *(.rudata)          }
    .bss        ALIGN(4096) : { *(.bss)             }
    /DISCARD/   ALIGN(4096) : { *(.comment) *(.eh_frame) }
}
