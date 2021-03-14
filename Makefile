VERSION ?= $(shell git tag --points-at HEAD | sed 's/^v//')
VERSION += 0-git-$(shell git rev-parse --short HEAD)
VERSION := $(word 1, $(VERSION))

PREFIX  ?= /usr

all:
	@echo "Nekofetch doesn't need to be compiled, run 'make install' to install"

options:
	@echo "VERSION: $(VERSION)"

install:
	mkdir -p $(PREFIX)/bin
	install -m 0755 hentaifetch $(PREFIX)/bin/hentaifetch
	@echo "You may need to install jq, jp2a, imagemagick and neofetch"

uninstall:
	rm -f $(PREFIX)/bin/hentaifetch

.PHONY: all options install uninstall 
