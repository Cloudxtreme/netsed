CFLAGS := -Wall -fomit-frame-pointer -O9

VERSION := $(shell grep '\#define VERSION' netsed.c|sed 's/\#define VERSION "\(.*\)"/\1/')

all: netsed

clean:
	rm -f netsed core *.o netsed.tgz

doc:
	doxygen doxygen.conf

check_version:
	@echo netsed $(VERSION)
	@grep $(VERSION) NEWS>/dev/null #version should appear in NEWS file
	@grep $(VERSION) README>/dev/null #same for README

.PHONY: test

test: netsed
	ruby test/ts_full.rb

release_tag: check_version
	git tag $(VERSION)

release_archive: clean check_version
	tar cfvz ../netsed-$(VERSION).tar.gz *

release: release_archive
	@echo "netsed-$(VERSION) release" > ../netsed-$(VERSION).txt
	@echo -n "commit " >> ../netsed-$(VERSION).txt
	@git rev-parse --verify $(VERSION) >> ../netsed-$(VERSION).txt
	@cd .. && md5sum netsed-$(VERSION).tar.gz >> netsed-$(VERSION).txt
	@cd .. && sha1sum netsed-$(VERSION).tar.gz >> netsed-$(VERSION).txt
	@cd .. && sha256sum netsed-$(VERSION).tar.gz >> netsed-$(VERSION).txt

# then: gpg --clearsign netsed-$(VERSION).txt -o netsed-$(VERSION).sig
# and upload netsed-$(VERSION).tar.gz netsed-$(VERSION).sig
