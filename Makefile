# based on https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel

KVER = $(shell uname -r)

# use the one downloaded via apt-get source, expand on use
# (yeah, really ugly, I know)
KDIR = $(dirname $(ls linux-*/MAINTAINERS))

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
	( cd "$(KDIR)" && fakeroot debian/rules clean )
	( cd "$(KDIR)" && fakeroot debian/rules binary-headers binary-generic )

.PHONY: install
	dpkg -i linux*.deb

