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
MPFR_VER		= 4.0.2
MPC_VER			= 1.1.0


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
$(SRC)/%/README: $(GZ)/%.tar.gz
	cd $(SRC) ;  zcat $< | tar -x && touch $@

.PHONY: cclibs
cclibs: gmp mpfr mpc

GMP		= gmp-$(GMP_VER)
MPFR	= mpfr-$(MPFR_VER)
MPC		= mpc-$(MPC_VER)

GMP_GZ	= $(GMP).tar.xz
MPFR_GZ	= $(MPFR).tar.xz
MPC_GZ	= $(MPC).tar.gz

CCLIBS_CFG	= --disable-shared --enable-static
GMP_CFG 	= $(CCLIBS_CFG)
MPFR_CFG 	= $(CCLIBS_CFG)
MPC_CFG 	= $(CCLIBS_CFG) --with-mpfr=$(CWD)/$(TARGET)

.PHONY: gmp
gmp: $(TARGET)/lib/libgmp.a
$(TARGET)/lib/libgmp.a: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP) ; cd $(TMP)/$(GMP) ;\
	$(XPATH) $(SRC)/$(GMP)/$(CFG) $(GMP_CFG) && $(MAKE) -j4 && $(MAKE) install

.PHONY: mpfr
mpfr: $(TARGET)/lib/libmpfr.a
$(TARGET)/lib/libmpfr.a: $(SRC)/$(MPFR)/README
	rm -rf $(TMP)/$(MPFR) ; mkdir $(TMP)/$(MPFR) ; cd $(TMP)/$(MPFR) ;\
	$(XPATH) $(SRC)/$(MPFR)/$(CFG) $(MPFR_CFG) && $(MAKE) -j4 && $(MAKE) install

.PHONY: mpc
mpc: $(TARGET)/lib/libmpc.a
$(TARGET)/lib/libmpc.a: $(SRC)/$(MPC)/README
	rm -rf $(TMP)/$(MPC) ; mkdir $(TMP)/$(MPC) ; cd $(TMP)/$(MPC) ;\
	$(XPATH) $(SRC)/$(MPC)/$(CFG) $(MPC_CFG) && $(MAKE) -j4 && $(MAKE) install

$(SRC)/$(GMP)/README:  $(GZ)/$(GMP_GZ)
$(SRC)/$(MPFR)/README: $(GZ)/$(MPFR_GZ)
$(SRC)/$(MPC)/README:  $(GZ)/$(MPC_GZ)

$(GZ)/$(GMP_GZ):
	$(WGET) -O $@ https://gmplib.org/download/gmp/$(GMP_GZ)
$(GZ)/$(MPFR_GZ):
	$(WGET) -O $@ https://www.mpfr.org/mpfr-current/$(MPFR_GZ)
$(GZ)/$(MPC_GZ):
	$(WGET) -O $@ https://ftp.gnu.org/gnu/mpc/$(MPC_GZ)
