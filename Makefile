prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/createmlfairy" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/createmlfairy"

clean:
	rm -rf .build

.PHONY: build install uninstall clean

