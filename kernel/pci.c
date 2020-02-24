// http://gitlab.unique-conception.org/snippets/53

#include <kernel.h>

uint16_t pci_readConfig()
{
}

void pci_init(void)
{
	putStr("pci_init:\n");
	putStr("\tbase: ");
	putHex(PCI_CONFIG_BASE);
	putStr("\n");
}
