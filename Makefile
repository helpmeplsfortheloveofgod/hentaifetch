VERSION ?= $(shell git tag --points-at HEAD | sed 's/^v//')
VERSION += 0-git-$(shell git rev-parse --short HEAD)
VERSION := $(word 1, $(VERSION))

PREFIX  ?= /usr

all:
	@echo "Nekofetch doesn't need to be compiled, run 'make install' to install"

debs: options iosdeb amd64deb

options:
	@echo "VERSION: $(VERSION)"

install:
	mkdir -p $(PREFIX)/bin
	install -m 0755 nekofetch $(PREFIX)/bin/nekofetch
	@echo "You may need to install jq, jp2a, and neofetch"

uninstall:
	rm -f $(PREFIX)/bin/nekofetch

ioscontrol:
	cp control.template ioscontrol
	sed -i 's/PACKAGE/com.propr.nekofetch/' ioscontrol
	sed -i 's/ARCH/iphoneos-arm/' ioscontrol
	sed -i 's/VERSION/$(VERSION)/' ioscontrol
amd64control:
	cp control.template amd64control
	sed -i 's/PACKAGE/nekofetch/' amd64control
	sed -i 's/ARCH/amd64/' amd64control
	sed -i 's/VERSION/$(VERSION)/' amd64control

iosdebroot: ioscontrol
	mkdir -p iosdebroot/DEBIAN
	mkdir -p iosdebroot/usr/bin
	cp ioscontrol iosdebroot/DEBIAN/control
	cp nekofetch iosdebroot/usr/bin/nekofetch
amd64debroot: amd64control
	mkdir -p amd64debroot/DEBIAN
	mkdir -p amd64debroot/usr/bin
	cp amd64control amd64debroot/DEBIAN/control
	cp nekofetch amd64debroot/usr/bin/nekofetch

iosdeb: iosdebroot
	dpkg-deb -b "iosdebroot" "com.propr.nekofetch_$(VERSION)_iphoneos-arm.deb"
amd64deb: amd64debroot
	dpkg-deb -b "amd64debroot" "nekofetch_$(VERSION)_amd64.deb"

clean:
	rm -rf iosdebroot amd64debroot
	rm -f ioscontrol amd64control
	rm -f com.propr.nekofetch_*_iphoneos-arm.deb nekofetch_*_amd64.deb

.PHONY: all debs options install uninstall clean iosdeb amd64deb
