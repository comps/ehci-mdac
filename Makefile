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
# since Ubuntu can have various kernel at various releases without any
# clear or predictable pattern, I'm going for brute force here
# - first patch to apply successfully wins
patch:
	@echo "Looping over available patches, trying one by one ..."; \
	patch_cmd="patch -f -d "$(KDIR)" --reject-file=- --no-backup-if-mismatch -p1"; \
	match=; \
	for i in patches/Ubuntu-*.patch; do \
	    echo "Trying $$i ..."; \
	    if $$patch_cmd --dry-run < "$$i" 1>/dev/null 2>&1; then \
	        match="$$i"; \
	        break; \
	    fi; \
	done; \
	if [ "$$match" ]; then \
	    echo "Patch $$match matched, applying for real ..."; \
	    if $$patch_cmd < "$$match"; then \
	        echo "Patch applied successfully!"; \
	    else \
	        echo "Verified patch failed to apply, this should not happen."; \
	    fi; \
	else \
	    echo "You have either run 'make patch' already"; \
	    echo "or your kernel version ($$(uname -r)) is not supported."; \
	fi

.PHONY: build
build:
	cd "$(KDIR)"; \
	unset MAKELEVEL; \
	fakeroot debian/rules clean binary-headers binary-generic

.PHONY: install
install:
	dpkg -i linux-image*.deb

