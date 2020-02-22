CWD    = $(CURDIR)
MODULE = $(notdir $(CWD))

NOW = $(shell date +%d%m%y)
REL = $(shell git rev-parse --short=4 HEAD)

.PHONY: all
all: $(MODULE)
	qemu-system-i386 -kernel $<

C = kernel.cc
H = kernel.hh

$(MODULE): $(C) $(H) Makefile
	gcc -m32 -c -o $@ $(C) && file $@
