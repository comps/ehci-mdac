# based on https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel
# (an Ubuntu-only version!)

KVER = $(shell uname -r)

# use the one downloaded via apt-get source, expand on use
# (yeah, really ugly, I know)
KDIR = `ls linux-*/MAINTAINERS | xargs dirname`

# "make" without args should only build
all: debpkg

debpkg: builddep source patch build

.PHONY: builddep
builddep:
	apt-get -y --no-install-recommends build-dep linux-image-$(KVER)
	# further needed deps
	apt-get -y --no-install-recommends install fakeroot patch

.PHONY: source
source:
	apt-get source linux-image-$(KVER)

.PHONY: patch
patch:
	@. /etc/lsb-release; \
	echo "Detected release: $$DISTRIB_RELEASE"; \
	case "$$DISTRIB_RELEASE" \
	in \
	    '12.04') \
	        patch -d "$(KDIR)" -p1 < patches/Ubuntu-3.2.0-59.90.patch;; \
	    '13.10') \
	        patch -d "$(KDIR)" -p1 < patches/Ubuntu-3.11.0-17.30.patch;; \
	    *) \
	        echo "This release is not supported.";; \
	esac

.PHONY: build
build:
	cd "$(KDIR)"; \
	unset MAKELEVEL; \
	fakeroot debian/rules clean binary-headers binary-generic

.PHONY: install
install:
	dpkg -i linux*.deb

