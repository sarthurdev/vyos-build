SHELL := /bin/bash

build_dir := build

.PHONY: all
all:
	@echo "Make what specifically?"
	@echo "The most common target is 'iso'"

.PHONY: iso
.ONESHELL:
iso: clean
	set -o pipefail
	@./build-vyos-image iso
	exit 0

.PHONY: prepare-package-env
.ONESHELL:
prepare-package-env:
	@set -e
	@scripts/pbuilder-config
	@scripts/pbuilder-setup

.PHONY: checkiso
.ONESHELL:
checkiso:
	if [ ! -f build/live-image-amd64.hybrid.iso ]; then
		echo "Could not find build/live-image-amd64.hybrid.iso"
		exit 1
	fi

.PHONY: test
.ONESHELL:
test: checkiso
	scripts/check-qemu-install --debug --uefi build/live-image-amd64.hybrid.iso

.PHONY: test-no-interfaces
.ONESHELL:
test-no-interfaces: checkiso
	scripts/check-qemu-install --debug --no-interfaces build/live-image-amd64.hybrid.iso

.PHONY: testd
.ONESHELL:
testd: checkiso
	scripts/check-qemu-install --debug --configd build/live-image-amd64.hybrid.iso

.PHONY: testc
.ONESHELL:
testc: checkiso
	scripts/check-qemu-install --debug --configd --configtest build/live-image-amd64.hybrid.iso

.PHONY: testraid
.ONESHELL:
testraid: checkiso
	scripts/check-qemu-install --debug --configd --raid --configtest build/live-image-amd64.hybrid.iso

.PHONY: testnetwork
.ONESHELL:
networktest: checkiso
	scripts/network-qemu-install --debug --agents 1 --uefi build/live-image-amd64.hybrid.iso

.PHONY: clean
.ONESHELL:
clean:
	@set -e
	mkdir -p $(build_dir)
	cd $(build_dir)
	lb clean

	rm -f config/binary config/bootstrap config/chroot config/common config/source
	rm -f build.log
	rm -f vyos-*.iso
	rm -f *.img
	rm -f *.xz
	rm -f *.vhd
	rm -f *.raw
	rm -f *.tar.gz
	rm -f *.qcow2
	rm -f *.mf
	rm -f *.ovf
	rm -f *.ova

.PHONY: purge
purge:
	rm -rf build packer_build packer_cache testinstall-*.img
