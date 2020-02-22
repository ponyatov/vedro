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
GCC0_CFG	 = $(BINUTILS_CFG) --enable-languages="c" \
				--with-gmp=$(CWD)/$(TARGET) --with-mpfr=$(CWD)/$(TARGET) --with-mpc=$(CWD)/$(TARGET) \
				--with-newlib --without-headers

.PHONY: binutils
binutils: $(LD)
.PHONY: gcc0
gcc0: cclibs $(CC)

$(LD):
	$(MAKE) $(SRC)/$(BINUTILS)/README
	mkdir -p $(TMP)/$(BINUTILS) ; cd $(TMP)/$(BINUTILS) ;\
	$(XPATH) $(SRC)/$(BINUTILS)/$(CFG) $(BINUTILS_CFG)
	cd $(TMP)/$(BINUTILS) ; $(MAKE) -j4 && $(MAKE) install
	rm -rf $(TMP)/$(BINUTILS) $(SRC)/$(BINUTILS)

$(CC): $(LD)
	$(MAKE) $(SRC)/$(GCC)/README
	mkdir -p $(TMP)/$(GCC) ; cd $(TMP)/$(GCC) ;\
	$(XPATH) $(SRC)/$(GCC)/$(CFG) $(GCC0_CFG)
	cd $(TMP)/$(GCC) ; $(XPATH) $(MAKE) -j4 all-gcc
	cd $(TMP)/$(GCC) ; $(XPATH) $(MAKE) install-gcc

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
$(TARGET)/lib/libgmp.a:
	$(MAKE) $(SRC)/$(GMP)/README
	mkdir -p $(TMP)/$(GMP) ; cd $(TMP)/$(GMP) ;\
	$(XPATH) $(SRC)/$(GMP)/$(CFG) $(GMP_CFG) && $(MAKE) -j4 && $(MAKE) install
	rm -rf $(TMP)/$(GMP) $(SRC)/$(GMP)

.PHONY: mpfr
mpfr: $(TARGET)/lib/libmpfr.a
$(TARGET)/lib/libmpfr.a:
	$(MAKE) $(SRC)/$(MPFR)/README
	mkdir -p $(TMP)/$(MPFR) ; cd $(TMP)/$(MPFR) ;\
	$(XPATH) $(SRC)/$(MPFR)/$(CFG) $(MPFR_CFG) && $(MAKE) -j4 && $(MAKE) install
	rm -rf $(TMP)/$(MPFR) $(SRC)/$(MPFR)

.PHONY: mpc
mpc: $(TARGET)/lib/libmpc.a
$(TARGET)/lib/libmpc.a:
	$(MAKE) $(SRC)/$(MPC)/README
	mkdir -p $(TMP)/$(MPC) ; cd $(TMP)/$(MPC) ;\
	$(XPATH) $(SRC)/$(MPC)/$(CFG) $(MPC_CFG) && $(MAKE) -j4 && $(MAKE) install
	rm -rf $(TMP)/$(MPC) $(SRC)/$(MPC)

$(SRC)/$(GMP)/README:  $(GZ)/$(GMP_GZ)
$(SRC)/$(MPFR)/README: $(GZ)/$(MPFR_GZ)
$(SRC)/$(MPC)/README:  $(GZ)/$(MPC_GZ)

$(GZ)/$(GMP_GZ):
	$(WGET) -O $@ https://gmplib.org/download/gmp/$(GMP_GZ)
$(GZ)/$(MPFR_GZ):
	$(WGET) -O $@ https://www.mpfr.org/mpfr-current/$(MPFR_GZ)
$(GZ)/$(MPC_GZ):
	$(WGET) -O $@ https://ftp.gnu.org/gnu/mpc/$(MPC_GZ)
