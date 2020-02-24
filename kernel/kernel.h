#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>
#include <boot.h>
#include <pci.h>

extern void init(uint32_t magic, struct mb_info *mbi);

static inline void outb(uint16_t port, uint8_t data)
{
	asm volatile("outb %0, %1" : : "a"(data), "Nd"(port));
}

static inline void outl(uint32_t port, uint32_t data)
{
	asm volatile("outl %0, %1" : : "a"(data), "Nd"(port));
}

#define QEMU_DEBUGCON (0xE9)

static inline void put(uint8_t c)
{
	outb(QEMU_DEBUGCON, c);
}

extern void _putHex(uint32_t x, uint8_t bytes);
#define putHex(x)                                                              \
	{                                                                      \
		_putHex(x, sizeof(x));                                         \
	}

extern void putStr(char *str);

#endif // KERNEL_H
