CURDIR := $(shell pwd)
USER := $(shell whoami)
DEPNOTIFY_URL := "https://files.nomad.menu/DEPNotify.zip"
DEPNOTIFY_ZIPPATH := $(CURDIR)/DEPNotify.zip
MUNKIPKG := /usr/local/bin/munkipkg
PKG_ROOT := $(CURDIR)/pkg/erase-install/payload
PKG_BUILD := $(CURDIR)/pkg/erase-install/build
PKG_ROOT_NOPYTHON := $(CURDIR)/pkg/erase-install-nopython/payload
PKG_BUILD_NOPYTHON := $(CURDIR)/pkg/erase-install-nopython/build
PKG_ROOT_DEPNOTIFY := $(CURDIR)/pkg/erase-install-depnotify/payload
PKG_BUILD_DEPNOTIFY := $(CURDIR)/pkg/erase-install-depnotify/build
PKG_VERSION := $(shell defaults read $(CURDIR)/pkg/erase-install/build-info.plist version)
IIM_URL := "https://raw.githubusercontent.com/grahampugh/macadmin-scripts/v$(PKG_VERSION)/installinstallmacos.py"
PYTHON := python3
PYTHON_VERSION := 3.10.2
PYTHON_INSTALLER_SCRIPT := $(CURDIR)/../relocatable-python/make_relocatable_python_framework.py
PYTHON_REQUIREMENTS := $(CURDIR)/requirements_python3.txt

all: build

.PHONY : build
build: 
	@echo "Copying erase-install.sh into /Library/Management/erase-install"
	mkdir -p "$(PKG_ROOT)/Library/Management/erase-install"
	cp "$(CURDIR)/erase-install.sh" "$(PKG_ROOT)/Library/Management/erase-install/erase-install.sh"
	chmod 755 "$(PKG_ROOT)/Library/Management/erase-install/erase-install.sh"

	@echo "Downloading installinstallmacos.py into /Library/Management/erase-install"
	curl -H 'Cache-Control: no-cache' -s "$(IIM_URL)" -o "$(PKG_ROOT)/Library/Management/erase-install/installinstallmacos.py"

	@echo "Installing Python into /Library/Management/erase-install"
	$(PYTHON) "$(PYTHON_INSTALLER_SCRIPT)" --destination "$(PKG_ROOT)/Library/Management/erase-install/" --python-version=$(PYTHON_VERSION) --os-version 11 --pip-requirements="$(PYTHON_REQUIREMENTS)" --upgrade-pip

	@echo "Making package in $(PKG_BUILD) directory"
	cd $(CURDIR)/pkg && python3 $(MUNKIPKG) erase-install
	open $(PKG_BUILD)

.PHONY : nopython
nopython: 
	@echo "Copying erase-install.sh into /Library/Management/erase-install"
	mkdir -p "$(PKG_ROOT_NOPYTHON)/Library/Management/erase-install"
	cp "$(CURDIR)/erase-install.sh" "$(PKG_ROOT_NOPYTHON)/Library/Management/erase-install/erase-install.sh"
	chmod 755 "$(PKG_ROOT_NOPYTHON)/Library/Management/erase-install/erase-install.sh"

	@echo "Downloading installinstallmacos.py into /Library/Management/erase-install"
	curl -H 'Cache-Control: no-cache' -s "$(IIM_URL)" -o "$(PKG_ROOT_NOPYTHON)/Library/Management/erase-install/installinstallmacos.py"

	@echo "Making package in $(PKG_BUILD_NOPYTHON) directory"
	cd $(CURDIR)/pkg && python3 $(MUNKIPKG) erase-install-nopython
	open $(PKG_BUILD_NOPYTHON)

.PHONY : depnotify
depnotify: 
	@echo "Copying erase-install.sh into /Library/Management/erase-install"
	mkdir -p "$(PKG_ROOT_DEPNOTIFY)/Library/Management/erase-install"
	cp "$(CURDIR)/erase-install.sh" "$(PKG_ROOT_DEPNOTIFY)/Library/Management/erase-install/erase-install.sh"
	chmod 755 "$(PKG_ROOT_DEPNOTIFY)/Library/Management/erase-install/erase-install.sh"

	@echo "Downloading installinstallmacos.py into /Library/Management/erase-install"
	curl -H 'Cache-Control: no-cache' -s "$(IIM_URL)" -o "$(PKG_ROOT_DEPNOTIFY)/Library/Management/erase-install/installinstallmacos.py"

	@echo "Installing Python into /Library/Management/erase-install"
	$(PYTHON) "$(PYTHON_INSTALLER_SCRIPT)" --destination "$(PKG_ROOT_DEPNOTIFY)/Library/Management/erase-install/" --python-version=$(PYTHON_VERSION) --os-version 11 --pip-requirements="$(PYTHON_REQUIREMENTS)" --upgrade-pip

	@echo "Downloading and extracting DEPNotify.app into /Applications/Utilities"
	mkdir -p "$(PKG_ROOT_DEPNOTIFY)/Applications/Utilities"
	curl -L "$(DEPNOTIFY_URL)" -o "$(DEPNOTIFY_ZIPPATH)"
	unzip -o "$(DEPNOTIFY_ZIPPATH)" -d "$(PKG_ROOT_DEPNOTIFY)/Applications/Utilities"
	chmod -R 755 "$(PKG_ROOT_DEPNOTIFY)/Applications/Utilities"
	rm -Rf "$(PKG_ROOT_DEPNOTIFY)/Applications/Utilities/__MACOSX"

	@echo "Making package in $(PKG_BUILD_DEPNOTIFY) directory"
	cd $(CURDIR)/pkg && python3 $(MUNKIPKG) erase-install-depnotify
	open $(PKG_BUILD_DEPNOTIFY)



.PHONY : clean
clean :
	@echo "Cleaning up package root"
	rm -Rf "$(PKG_ROOT)/Library/Management/erase-install/"* ||:
	rm -Rf "$(PKG_ROOT_NOPYTHON)/Library/Management/erase-install/"* ||:
	rm -Rf "$(PKG_ROOT_DEPNOTIFY)/Library/Management/erase-install/"* ||:
	rm -Rf "$(PKG_ROOT_DEPNOTIFY)/Applications/Utilities/"* ||:
	rm $(CURDIR)/pkg/erase-install/build/*.pkg ||:
	rm $(CURDIR)/pkg/erase-install-nopython/build/*.pkg ||:
	rm $(CURDIR)/pkg/erase-install-depnotify/build/*.pkg ||:
	rm -Rf $(CURDIR)/pkg/erase-install/payload ||:
	rm -Rf $(CURDIR)/pkg/erase-install-nopython/payload ||:
	rm -Rf $(CURDIR)/pkg/erase-install-depnotify/payload ||:
	rm -Rf /Users/$(USER)/Library/Python/3.9/lib/python/site-packages