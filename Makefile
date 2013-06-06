ifneq ($(KERNELRELEASE),)

obj-m += ehci-hcd.o

else

KVER = $(shell uname -r)
KCONFIG = /boot/config-$(KVER)
JOBS = 4

# ehci-hcd.c includes *.c files from the source tree (!!!)
#KDIR ?= /lib/modules/$(KVER)/source

# use the one downloaded via apt-get source, expand on use
# (yeah, really ugly, I know)
KDIR = $(dirname $(ls linux-*/MAINTAINERS))

#EXTRA_CFLAGS += -Idrivers/usb/host


all: builddep source_prepare patch build

.PHONY: clean
clean:
	#todo
	echo .

.PHONY: builddep
builddep:
	apt-get -y build-dep --no-install-recommends linux-image-$(KVER)

# full module build is needed to generate Module.symvers,
# "modules_prepare" just won't do
.PHONY: source_prepare
source_prepare:
	@[ -f "$(KCONFIG)" ] || { \
		echo "kernel config not found at $(KCONFIG)"; \
		exit 1; \
	}
	apt-get source linux-image-$(KVER)
	cp -v "$(KCONFIG)" "$(KDIR)/.config"
	$(MAKE) -j$(JOBS) -C "$(KDIR)" modules

# todo: kernel autodetection?
.PHONY: patch
patch:
	patch -d "$(KDIR)" -j1 < patches/Ubuntu-3.8.0-23.34.patch


.PHONY: build
build:
	#$(MAKE) -C "$(KDIR)" M="$$PWD" EXTRA_CFLAGS="$(EXTRA_CFLAGS)"


endif
