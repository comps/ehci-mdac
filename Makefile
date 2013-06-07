# based on https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel
# (an Ubuntu-only version!)

KVER = $(shell uname -r)

# use the one downloaded via apt-get source, expand on use
# (yeah, really ugly, I know)
KDIR = `ls linux-*/MAINTAINERS | xargs dirname`

all: builddep source patch build

.PHONY: builddep
builddep:
	apt-get -y --no-install-recommends build-dep linux-image-$(KVER)
	# further needed deps
	apt-get -y --no-install-recommends install fakeroot patch

.PHONY: source
source:
	apt-get source linux-image-$(KVER)

# todo: kernel autodetection?
.PHONY: patch
patch:
	patch -d "$(KDIR)" -p1 < patches/Ubuntu-3.8.0-23.34.patch

.PHONY: build
build:
	cd "$(KDIR)"; \
	unset MAKELEVEL; \
	fakeroot debian/rules clean binary-headers binary-generic

.PHONY: install
install: builddep source patch build
	dpkg -i linux*.deb

