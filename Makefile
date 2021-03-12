VERSION ?= $(shell git tag --points-at HEAD | sed 's/^v//')
VERSION += 0-git-$(shell git rev-parse --short HEAD)
VERSION := $(word 1, $(VERSION))

PREFIX  ?= /usr

all:
	@echo "Nekofetch doesn't need to be compiled, run 'make install' to install"

debs: options iosdeb amd64deb

debroots: options iosdebroot amd64debroot

controls: options ioscontrol amd64control

options:
	@echo "VERSION: $(VERSION)"

install:
	mkdir -p $(PREFIX)/bin
	install -m 0755 hentaifetch $(PREFIX)/bin/hentaifetch
	@echo "You may need to install jq, jp2a, and neofetch"
	@echo "imagemagick is also required to use the kitty image backend"

uninstall:
	rm -f $(PREFIX)/bin/hentaifetch

ioscontrol:
	cp control.template ioscontrol
	sed -i 's/PACKAGE/com.propr.hentaifetch/' ioscontrol
	sed -i 's/ARCH/iphoneos-arm/' ioscontrol
	sed -i 's/VERSION/$(VERSION)/' ioscontrol
amd64control:
	cp control.template amd64control
	sed -i 's/PACKAGE/hentaifetch/' amd64control
	sed -i 's/ARCH/amd64/' amd64control
	sed -i 's/VERSION/$(VERSION)/' amd64control

iosdebroot: ioscontrol
	mkdir -p iosdebroot/DEBIAN
	mkdir -p iosdebroot/usr/bin
	mkdir -p iosdebroot/usr/share/doc/hentaifetch
	cp ioscontrol iosdebroot/DEBIAN/control
	cp LICENSE iosdebroot/usr/share/doc/hentaifetch/copyright
	cp hentaifetch iosdebroot/usr/bin/hentaifetch
amd64debroot: amd64control
	mkdir -p amd64debroot/DEBIAN
	mkdir -p amd64debroot/usr/bin
	mkdir -p amd64debroot/usr/share/doc/hentaifetch
	cp amd64control amd64debroot/DEBIAN/control
	cp LICENSE amd64debroot/usr/share/doc/hentaifetch/copyright
	cp hentaifetch amd64debroot/usr/bin/hentaifetch

iosdeb: iosdebroot
	dpkg-deb -b "iosdebroot" "com.propr.hentaifetch_$(VERSION)_iphoneos-arm.deb"
amd64deb: amd64debroot
	dpkg-deb -b "amd64debroot" "hentaifetch_$(VERSION)_amd64.deb"

clean:
	rm -rf iosdebroot amd64debroot
	rm -f ioscontrol amd64control
	rm -f com.propr.hentaifetch_*_iphoneos-arm.deb hentaifetch_*_amd64.deb

.PHONY: all debs debroots controls options install uninstall iosdeb amd64deb clean
