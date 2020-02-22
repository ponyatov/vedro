/* https://github.com/qemu/qemu/blob/master/tests/multiboot/link.ld */

ENTRY(_init)

SECTIONS {
    . = 0x100000;
    _start = .;
    .text       : { *(.boot) *(.text)   }
    .data       : { *(.data)            }
    .rodata     : { *(.rudata)          }
    .bss        : { *(.bss)             }
    /DISCARD/   : { *(.comment)         }
}
