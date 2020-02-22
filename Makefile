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

C = kernel.cc
H = kernel.hh

CC = $(TARGET)/bin/gcc
LD = $(TARGET)/bin/ld

$(MODULE): $(CC) $(C) $(H) Makefile
	$(CC) -m32 -c -o $@ $(C) && file $@


BINUTILS_VER	= 2.34
BINUTILS		= binutils-$(BINUTILS_VER)
BINUTILS_GZ		= $(BINUTILS).tar.xz

$(CC): $(LD)

$(LD):
	$(MAKE) binutils

.PHONY: binutils
binutils: $(SRC)/$(BINUTILS)/README

$(SRC)/$(BINUTILS)/README: $(GZ)/$(BINUTILS_GZ)

$(GZ)/$(BINUTILS_GZ):
	$(WGET) -O $@ http://ftp.gnu.org/gnu/binutils/binutils-2.34.tar.xz

$(SRC)/%/README: $(GZ)/%.tar.xz
	cd $(SRC) ; xzcat $< | tar -x && touch $@
