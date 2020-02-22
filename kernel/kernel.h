#ifndef KERNEL_H
#define KERNEL_H

#include <boot.h>

#include <stdint.h>

extern void init(uint32_t magic, struct mb_info *mbi);

static inline void outb(uint16_t port, uint8_t data) {
  asm volatile("outb %0, %1" : : "a"(data), "Nd"(port));
}

static inline void put(uint8_t c) { outb(0xe9, c); }

#endif // KERNEL_H
