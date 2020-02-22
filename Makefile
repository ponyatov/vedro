TARGET = i486-elf

CWD    	= $(CURDIR)
MODULE	= $(notdir $(CWD))

GZ		= $(HOME)/gz
TMP		= $(CWD)/tmp
SRC		= $(TMP)/src

NOW = $(shell date +%d%m%y)
REL = $(shell git rev-parse --short=4 HEAD)

WGET = wget -c --no-check-certificate

.PHONY: all
all: $(MODULE)
	qemu-system-i386 -kernel $<

C = kernel/kernel.cc
H = kernel/kernel.hh

CC = $(TARGET)/bin/$(TARGET)-gcc
LD = $(TARGET)/bin/$(TARGET)-ld

$(MODULE): $(CC) $(C) $(H) Makefile
	$(CC) -m32 -c -o $@ $(C) && file $@


BINUTILS_VER	= 2.34
GCC_VER			= 9.2.0
GMP_VER			= 6.2.0

BINUTILS		= binutils-$(BINUTILS_VER)
BINUTILS_GZ		= $(BINUTILS).tar.xz

GCC				= gcc-$(GCC_VER)
GCC_GZ			= $(GCC).tar.xz

CFG = configure --disable-nls --prefix=$(CWD)/$(TARGET)

XPATH = PATH=$(CWD)/$(TARGET)/bin:$(PATH)

BINUTILS_CFG = --target=$(TARGET) --with-sysroot=$(TARGET)/sysroot
GCC_CFG		 = $(BINUTILS_CFG) --enable-languages="c"

.PHONY: binutils
binutils: $(LD) $(CC)
.PHONY: gcc
gcc: cclibs $(CC)

$(LD): $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS) ; cd $(TMP)/$(BINUTILS) ;\
	$(XPATH) $(SRC)/$(BINUTILS)/$(CFG) $(BINUTILS_CFG) && $(MAKE) -j4 && $(MAKE) install
	touch $@

$(CC): $(LD) $(SRC)/$(GCC)/README
	rm -rf $(TMP)/$(GCC) ; mkdir $(TMP)/$(GCC) ; cd $(TMP)/$(GCC) ;\
	$(XPATH) $(SRC)/$(GCC)/$(CFG) $(GCC_CFG)

$(SRC)/$(BINUTILS)/README	: $(GZ)/$(BINUTILS_GZ)
$(SRC)/$(GCC)/README		: $(GZ)/$(GCC_GZ)

$(GZ)/$(BINUTILS_GZ):
	$(WGET) -O $@ http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ)
$(GZ)/$(GCC_GZ):
	$(WGET) -O $@ http://mirror.linux-ia64.org/gnu/gcc/releases/$(GCC)/$(GCC_GZ)

$(SRC)/%/README: $(GZ)/%.tar.xz
	cd $(SRC) ; xzcat $< | tar -x && touch $@

.PHONY: cclibs
cclibs: gmp mpfr mpc

GMP = gmp-$(GMP_VER)
GMP_GZ	= $(GMP).tar.xz

CCLIBS_CFG	= --disable-shared --enable-static
GMP_CFG 	= $(CCLIBS_CFG)

.PHONY: gmp
gmp: $(TARGET)/lib/libgmp.a
$(TARGET)/lib/libgmp.a: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP) ; cd $(TMP)/$(GMP) ;\
	$(XPATH) $(SRC)/$(GMP)/$(CFG) $(GMP_CFG) && $(MAKE) -j4 && $(MAKE) install
$(SRC)/$(GMP)/README: $(GZ)/$(GMP_GZ)
$(GZ)/$(GMP_GZ):
	$(WGET) -O $@ https://gmplib.org/download/gmp/$(GMP_GZ)
