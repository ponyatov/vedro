#ifndef PCI_H
#define PCI_H

#define PCI_CONFIG_ADDRESS (0xCF8)
#define PCI_CONFIG_DATA (0xCFC)
#define PCI_CONFIG_BASE (0x80000000UL)

extern void pci_init(void);

#endif // PCI_H
