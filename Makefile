# based on https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel
# (an Ubuntu-only version!)

KVER = $(shell uname -r)

all: source builddep patch build install

.PHONY: source
source:
	apt-get source linux-image-$(KVER)

.PHONY: builddep
builddep:
	apt-get -y --no-install-recommends build-dep linux-image-$(KVER)
	# further needed deps
	apt-get -y --no-install-recommends install fakeroot patch

# todo: kernel autodetection?
.PHONY: patch
patch:
	patch -d "$(KDIR)" -p1 < patches/Ubuntu-3.8.0-23.34.patch

.PHONY: build
build:
	cd "`ls linux-*/MAINTAINERS | xargs dirname`"; \
	unset MAKELEVEL; \
	fakeroot debian/rules clean binary-headers binary-generic

.PHONY: install
install:
	dpkg -i linux*.deb

