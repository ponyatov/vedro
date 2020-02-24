#include <kernel.h>

const char hello[] = "Hello World";

void init(uint32_t magic, struct mb_info *mbi)
{
	for (char *c = (char *)hello; *c != 0; c++)
		put(*c);
	put('\n');
	pci_init();
}

void _putHex(uint32_t x, uint8_t bytes)
{
	const int width = bytes * 2;
	uint8_t c;
	for (int i = width - 1; i >= 0; i--) {
		c = (x >> (4 * i)) & 0xF;
		c = c + '0';
		if (c > '9')
			c += 'A' - '9' - 1;
		put(c);
	}
}

void putStr(char *str)
{
	for (char *c = str; *c != 0; c++)
		put(*c);
}
