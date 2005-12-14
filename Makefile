#
# $Id$
#
# Copyright (C) 2002-2005 by The PTXdist Team - See CREDITS for Details
#

PROJECT			:= PTXdist
VERSION			:= 0
PATCHLEVEL		:= 7
SUBLEVEL		:= 8
EXTRAVERSION		:=-rc3(r3496-729)

FULLVERSION		:= $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

export PROJECT VERSION PATCHLEVEL SUBLEVEL EXTRAVERSION FULLVERSION

#
# For out-of-tree builds we have to find out where the Makefile
# _reall_ lives; it may happen that somebody has created a softlink
#
# FIXME: how to make sure that we have at least make 3.80?
#

ifneq ($(MAKEFILE_LIST),)
 # Since 3.80, we can find out which Makefile is currently processed,
 # and infere the location of the source tree using MAKEFILE_LIST.
 TOPLEVEL_MAKEFILE := $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
 TOPLEVEL_MAKEFILE := $(shell \
	if [ -L "$(TOPLEVEL_MAKEFILE)" ]; then \
		find $(TOPLEVEL_MAKEFILE) -printf "%l"; \
	else \
		echo "$(TOPLEVEL_MAKEFILE)"; \
	fi \
 )
 OUTOFTREE := $(shell [ -L "$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))" ] && echo 1)
endif

PTXDIST_TOPDIR := $(shell dirname $(TOPLEVEL_MAKEFILE))
ifeq ($(PTXDIST_TOPDIR),)
PTXDIST_TOPDIR := $(shell test -d rules && pwd)
endif
ifeq ($(PTXDIST_TOPDIR),)
$(error Please specify the location of your source tree: make PTXDIST_TOPDIR=...)
endif
override PTXDIST_TOPDIR	:= $(shell cd $(PTXDIST_TOPDIR) && pwd)

#
# Now define the rest of the directories
#
# Make has the directory of the Makefile in $(CURDIR) 
#

HOME			:= $(shell echo $$HOME)

PTXDIST_WORKSPACE	:= $(CURDIR)

PATCHDIR		:= $(PTXDIST_TOPDIR)/patches
MISCDIR			:= $(PTXDIST_TOPDIR)/misc
RULESDIR		:= $(PTXDIST_TOPDIR)/rules

BUILDDIR		:= $(PTXDIST_WORKSPACE)/build-target
CROSS_BUILDDIR		:= $(PTXDIST_WORKSPACE)/build-cross
HOST_BUILDDIR		:= $(PTXDIST_WORKSPACE)/build-host
STATEDIR		:= $(PTXDIST_WORKSPACE)/state
IMAGEDIR		:= $(PTXDIST_WORKSPACE)/images
ROOTDIR			:= $(PTXDIST_WORKSPACE)/root

include $(RULESDIR)/Definitions.make

ifneq ($(wildcard $(HOME)/.ptxdistrc),)
include $(HOME)/.ptxdistrc
else
include $(PTXDIST_TOPDIR)/config/setup/ptxdistrc.default
endif

-include $(PTXDIST_WORKSPACE)/.config

SRCDIR			:= $(strip $(call remove_quotes, $(PTXCONF_SETUP_SRCDIR)))

# ----------------------------------------------------------------------------
# Setup a list of project directories
# ----------------------------------------------------------------------------

PROJECTDIRS		:= 
ifeq (exists, $(shell test -e $(PTXCONF_SETUP_PROJECTDIR1) && echo exists))
PROJECTDIRS		+= $(PTXCONF_SETUP_PROJECTDIR1)/
endif
ifeq (exists, $(shell test -e $(PTXCONF_SETUP_PROJECTDIR2) && echo exists))
PROJECTDIRS		+= $(PTXCONF_SETUP_PROJECTDIR2)/
endif
PROJECTDIRS		+= $(wildcard $(PTXDIST_WORKSPACE)/project-*)

PROJECTDIRS		:= $(strip $(PROJECTDIRS))
 
PROJECTCONFFILE		:= $(shell find $(PROJECTDIRS) -name $(PTXCONF_PROJECT).ptxconfig)
PROJECTDIR		:= $(strip $(shell test -z "$(PROJECTCONFFILE)" || dirname $(PROJECTCONFFILE)))
PROJECTRULES		:= $(wildcard $(PROJECTDIR)/rules/*.make)
PROJECTRULESDIR		:= $(PROJECTDIR)/rules
PROJECTPATCHDIR		:= $(PROJECTDIR)/patches

MENU			:=  $(shell 						\
				if [ -e $(PROJECTDIR)/Kconfig ]; then		\
					echo $(PROJECTDIR)/Kconfig; 		\
				else 						\
					echo $(PTXDIST_TOPDIR)/config/Kconfig;	\
				fi						\
			   )

# ----------------------------------------------------------------------------
# Packets for host, cross and target
# ----------------------------------------------------------------------------

PACKAGES           =
CROSS_PACKAGES     =
HOST_PACKAGES      =
VIRTUAL            =

export TAR PTXDIST_TOPDIR BUILDDIR ROOTDIR SRCDIR PTXSRCDIR STATEDIR HOST_PACKAGES-y CROSS_PACKAGES-y PACKAGES-y

# ----------------------------------------------------------------------------
# PTXCONF_PREFIX can be overwritten from the make var PREFIX 
# ----------------------------------------------------------------------------

ifdef PREFIX
PTXCONF_PREFIX=$(PREFIX)
PREFIX=
endif

ifeq ($(PTXCONF_PREFIX),)
PTXCONF_PREFIX=$(PTXDIST_WORKSPACE)/local
endif

# FIXME: this should be removed some day...
PTXCONF_TARGET_CONFIG_FILE ?= none
ifeq ("", $(PTXCONF_TARGET_CONFIG_FILE))
PTXCONF_TARGET_CONFIG_FILE = none
endif
-include config/arch/$(call remove_quotes,$(PTXCONF_TARGET_CONFIG_FILE))
# /FIXME

# ----------------------------------------------------------------------------
# Include all rule files
# ----------------------------------------------------------------------------

all: help

include $(RULESDIR)/Rules.make
include $(RULESDIR)/Version.make

TMP_PROJECTRULES_IN = $(filter-out 			\
		$(RULESDIR)/Virtual.make 		\
		$(RULESDIR)/Rules.make 			\
		$(RULESDIR)/Version.make 		\
		$(RULESDIR)/Definitions.make,		\
		$(wildcard $(RULESDIR)/*.make)		\
) $(PROJECTRULES)

TMP_PROJECTRULES_FINAL = $(shell 			\
	$(PTXDIST_TOPDIR)/scripts/select_projectrules 	\
	"$(PTXDIST_TOPDIR)/rules" 				\
	"$(PROJECTDIR)/rules" 				\
	"$(TMP_PROJECTRULES_IN)" 			\
)

include $(TMP_PROJECTRULES_FINAL)

include $(RULESDIR)/Virtual.make

PACKAGES = $(PACKAGES-y)
CROSS_PACKAGES = $(CROSS_PACKAGES-y)
HOST_PACKAGES = $(HOST_PACKAGES-y)
VIRTUAL = $(VIRTUAL-y)

ALL_PACKAGES = $(PACKAGES-y) $(PACKAGES-) $(CROSS_PACKAGES) $(CROSS_PACKAGES-) $(HOST_PACKAGES) $(HOST_PACKAGES-)

# ----------------------------------------------------------------------------
# Install targets 
# ----------------------------------------------------------------------------

PACKAGES_TARGETINSTALL 	:= $(addsuffix _targetinstall,$(PACKAGES)) $(addsuffix _targetinstall,$(VIRTUAL))
PACKAGES_GET		:= $(addsuffix _get,$(PACKAGES))
PACKAGES_EXTRACT	:= $(addsuffix _extract,$(PACKAGES))
PACKAGES_PREPARE	:= $(addsuffix _prepare,$(PACKAGES))
PACKAGES_COMPILE	:= $(addsuffix _compile,$(PACKAGES))
HOST_PACKAGES_INSTALL	:= $(addsuffix _install,$(HOST_PACKAGES))
HOST_PACKAGES_GET	:= $(addsuffix _get,$(HOST_PACKAGES))
HOST_PACKAGES_EXTRACT	:= $(addsuffix _extract,$(HOST_PACKAGES))
HOST_PACKAGES_PREPARE	:= $(addsuffix _prepare,$(HOST_PACKAGES))
HOST_PACKAGES_COMPILE	:= $(addsuffix _compile,$(HOST_PACKAGES))
CROSS_PACKAGES_INSTALL	:= $(addsuffix _install,$(CROSS_PACKAGES))
CROSS_PACKAGES_GET	:= $(addsuffix _get,$(CROSS_PACKAGES))
CROSS_PACKAGES_EXTRACT	:= $(addsuffix _extract,$(CROSS_PACKAGES))
CROSS_PACKAGES_PREPARE	:= $(addsuffix _prepare,$(CROSS_PACKAGES))
CROSS_PACKAGES_COMPILE	:= $(addsuffix _compile,$(CROSS_PACKAGES))

# FIXME: should probably go somewhere else (separate images.make?)
ifdef PTXCONF_MKNBI_NBI
MKNBI_EXT = "nbi"
else
MKNBI_EXT = "elf"
endif

ifdef PTXCONF_USE_EXTERNAL_KERNEL
MKNBI_KERNEL = $(PTXCONF_IMAGE_MKNBI_EXT_KERNEL)
else
MKNBI_KERNEL = $(KERNEL_TARGET_PATH)
endif

MKNBI_ROOTFS = $(IMAGEDIR)/root.ext2
ifdef PTXCONF_IMAGE_EXT2_GZIP
MKNBI_ROOTFS = $(IMAGEDIR)/root.ext2.gz
endif

# ----------------------------------------------------------------------------
# Targets
# ----------------------------------------------------------------------------

help:
	@echo
	@echo "PTXdist - Build System for Embedded Linux Systems"
	@echo
	@echo "Most Useful Targets:"
	@echo
	@echo "  make projects                     show predefined project configs"
	@echo "  make setup                        setup PTXdist per-user-preferences"
	@echo "  make menuconfig|xconfig|gconfig   configure the root filesystem"
	@echo
	@echo "  make world                        make-everything-and-be-happy"
	@echo "  make run                          run simulation (only works in NATIVE=1 mode)"
	@echo
	@echo "  make imagesclean                  cleanup images directory"
	@echo "  make rootclean                    cleanup root directory for target"
	@echo "  make projectclean                 cleanup build-target directory"
	@echo "  make clean                        cleanup build-host and build-cross dirs"
	@echo "  make distclean                    cleanup everything"
	@echo
	@echo "  make images                       build root filesystem images"
	@echo "  make svn-up                       run \"svn update\" in topdir and project dir"
	@echo "  make svn-stat                     run \"svn stat\" in topdir and project dir"
	@echo
	@echo "Targets for Testing & QA:"
	@echo
	@echo "  make cuckoo-test                  search for cuckoo-eggs in root system"
	@echo "  make config-test                  run oldconfig on all ptxconfig files"
	@echo "  make ipkg-test                    check if ipkg packets are consistent "
	@echo "                                    with ROOTDIR"
	@echo "  make qa                           run qa checks from scripts/qa"
	@echo
	@echo "Targets for Autobuilding:"
	@echo
	@echo "  make toolchains                   build all supported toolchains"
	@echo "  make compile-test                 compile all supported targets, with report"
	@echo
#	@echo "Temporarily Broken:"
#	@echo
#	@echo "  make get                          download (most) of the needed packets"
#	@echo "  make extract                      extract all needed archives"
#	@echo "  make prepare                      prepare the configured system "
#	@echo "                                    for compilation"
#	@echo "  make compile                      compile the packages"
#	@echo "  make install                      install to rootdirectory"
#	@echo
	@echo "Make Variables:"
	@echo
	@echo "  NATIVE=1                          build with native compiler "
	@echo "                                    instead of cross compiler"
	@echo "  PREFIX=<path>                     build into this directory, instead of"
	@echo "                                    building into PTXCONF_PREFIX from config"
	@echo


# FIXME: this is not fully working yet, do to dependencies being defined
# in make files and Kconfig files in a non-consistent way. 
#
# get:     check_tools getclean $(PACKAGES_GET)
# extract: check_tools $(PACKAGES_EXTRACT)
# prepare: check_tools $(PACKAGES_PREPARE)
# compile: check_tools $(PACKAGES_COMPILE)
# install: check_tools $(PACKAGES_TARGETINSTALL)

dep_output_clean:
#	if [ -e $(DEP_OUTPUT) ]; then rm -f $(DEP_OUTPUT); fi
	touch $(DEP_OUTPUT)

dep_tree: $(STATEDIR)/dep_tree

$(STATEDIR)/dep_tree:
ifndef NATIVE
	@echo "Launching cuckoo-test"
	@$(PTXDIST_TOPDIR)/scripts/cuckoo-test $(PTXCONF_ARCH) $(ROOTDIR) $(PTXCONF_COMPILER_PREFIX)
ifdef PTXCONF_IMAGE_IPKG
	@echo "Launching ipkg-test"
	@IMAGES=$(IMAGEDIR) ROOT=$(ROOTDIR) IPKG=$(PTXCONF_PREFIX)/bin/ipkg-cl $(PTXDIST_TOPDIR)/scripts/ipkg-test
endif
endif
	@if dot -V 2> /dev/null; then \
		echo "creating dependency graph..."; \
		sort $(DEP_OUTPUT) | uniq | scripts/makedeptree | $(DOT) -Tps > $(DEP_TREE_PS); \
		if [ -x "`which poster`" ]; then \
			echo "creating A4 version..."; \
			poster -v -c0\% -mA4 -o$(DEP_TREE_A4_PS) $(DEP_TREE_PS); \
		fi;\
	else \
		echo "Install 'dot' from graphviz packet if you want to have a nice dependency tree"; \
	fi
	$(call touch, $@)

dep_world: $(HOST_PACKAGES_INSTALL) \
	   $(CROSS_PACKAGES_INSTALL) \
	   $(PACKAGES_TARGETINSTALL)
	@echo $@ : $^ | sed  -e 's/\([^ ]*\)_\([^_]*\)/\1.\2/g' >> $(DEP_OUTPUT)

world: check_tools dep_output_clean dep_world $(BOOTDISK_TARGETINSTALL) dep_tree 

host-tools:    check_tools dep_output_clean $(HOST_PACKAGES_INSTALL)  dep_tree
host-get:      check_tools getclean $(HOST_PACKAGES_GET) 
host-extract:  check_tools $(HOST_PACKAGES_EXTRACT)
host-prepare:  check_tools $(HOST_PACKAGES_PREPARE)
host-compile:  check_tools $(HOST_PACKAGES_COMPILE)
host-install:  check_tools $(HOST_PACKAGES_INSTALL)

cross-tools:   check_tools dep_output_clean $(CROSS_PACKAGES_INSTALL)  dep_tree
cross-get:     check_tools getclean $(CROSS_PACKAGES_GET) 
cross-extract: check_tools $(CROSS_PACKAGES_EXTRACT)
cross-prepare: check_tools $(CROSS_PACKAGES_PREPARE)
cross-compile: check_tools $(CROSS_PACKAGES_COMPILE)
cross-install: check_tools $(CROSS_PACKAGES_INSTALL)

# Robert-is-faster-typing-than-thinking shortcut
owrld: world

#
# Things which have to be done before _any_ suffix rule is executed
# (especially PTXDIST_PATH handling)
#

$(PACKAGES_PREPARE): before_prepare
before_prepare:
	@for path in `echo $(PTXDIST_PATH) | awk -F: '{for (i=1; i<=NF; i++) {print $$i}}'`; do \
		if [ ! -d $$path ]; then							\
			echo "warning: PTXDIST_PATH component \"$$path\" is no directory";	\
		fi;										\
	done;

# ----------------------------------------------------------------------------
# Images
# ----------------------------------------------------------------------------

DOPERMISSIONS = '{	\
	if ($$1 == "f")	\
		printf("chmod %s .%s; chown %s.%s .%s;\n", $$5, $$2, $$3, $$4, $$2);	\
	if ($$1 == "n")	\
		printf("mknod -m %s .%s %s %s %s; chown %s.%s .%s;\n", $$5, $$2, $$6, $$7, $$8, $$3, $$4, $$2);}'

images: $(STATEDIR)/images

ipkg-push: images
	$(PTXDIST_TOPDIR)/scripts/ipkg-push -i $(IMAGEDIR) -d $(PTXCONF_SETUP_IPKG_REPOSITORY)
	rm -f $(PTXCONF_SETUP_IPKG_REPOSITORY)/Packages
	PYTHONPATH=$(PTXCONF_PREFIX)/lib/python2.3/site-packages 		\
		$(PTXCONF_PREFIX)/bin/ipkg-make-index 				\
			-p $(PTXCONF_SETUP_IPKG_REPOSITORY)/Packages 		\
			$(PTXCONF_SETUP_IPKG_REPOSITORY)

ipkg-push-force: images
	$(PTXDIST_TOPDIR)/scripts/ipkg-push -i $(IMAGEDIR) -d $(PTXCONF_SETUP_IPKG_REPOSITORY) -f 
	rm -f $(PTXCONF_SETUP_IPKG_REPOSITORY)/Packages
	PYTHONPATH=$(PTXCONF_PREFIX)/lib/python2.3/site-packages 		\
		$(PTXCONF_PREFIX)/bin/ipkg-make-index 				\
			-p $(PTXCONF_SETUP_IPKG_REPOSITORY)/Packages 		\
			$(PTXCONF_SETUP_IPKG_REPOSITORY)

$(STATEDIR)/images: world
ifdef PTXCONF_IMAGE_TGZ
	cd $(ROOTDIR); \
	($(AWK) -F: $(DOPERMISSIONS) $(IMAGEDIR)/permissions && \
	echo "tar -zcvf $(IMAGEDIR)/root.tgz . ") | $(FAKEROOT) --
endif
ifdef PTXCONF_IMAGE_JFFS2
ifdef PTXCONF_IMAGE_IPKG
	PATH=$(PTXCONF_PREFIX)/bin:$$PATH $(PTXDIST_TOPDIR)/scripts/make_image_root.sh	\
		-i $(IMAGEDIR)							\
		-p $(IMAGEDIR)/permissions					\
		-e $(PTXCONF_IMAGE_JFFS2_BLOCKSIZE)				\
		-j $(PTXCONF_IMAGE_JFFS2_EXTRA_ARGS)				\
		-o $(IMAGEDIR)/root.jffs2
else
	PATH=$(PTXCONF_PREFIX)/bin:$$PATH $(PTXDIST_TOPDIR)/scripts/make_image_root.sh	\
		-r $(ROOTDIR)							\
		-p $(IMAGEDIR)/permissions					\
		-e $(PTXCONF_IMAGE_JFFS2_BLOCKSIZE)				\
		-j $(PTXCONF_IMAGE_JFFS2_EXTRA_ARGS)				\
		-o $(IMAGEDIR)/root.jffs2
endif
endif
ifdef PTXCONF_IMAGE_HD
	$(PTXDIST_TOPDIR)/scripts/genhdimg \
	-m $(GRUB_DIR)/stage1/stage1 \
	-n $(GRUB_DIR)/stage2/stage2 \
	-r $(ROOTDIR) \
	-i images \
	-f $(PTXCONF_IMAGE_HD_CONF)
endif
ifdef PTXCONF_IMAGE_EXT2
	cd $(ROOTDIR); \
	($(AWK) -F: $(DOPERMISSIONS) $(IMAGEDIR)/permissions && \
	( \
		echo -n "$(PTXCONF_HOST_PREFIX)/bin/genext2fs "; \
		echo -n "-b $(PTXCONF_IMAGE_EXT2_SIZE) "; \
		echo -n "$(PTXCONF_IMAGE_EXT2_EXTRA_ARGS) "; \
		echo -n "-d $(ROOTDIR) "; \
		echo "$(IMAGEDIR)/root.ext2" ) \
	) | $(FAKEROOT) --
endif
ifdef PTXCONF_IMAGE_EXT2_GZIP
	rm -f $(IMAGEDIR)/root.ext2.gz
	gzip -v9 $(IMAGEDIR)/root.ext2
endif
ifdef PTXCONF_IMAGE_UIMAGE
	$(PTXCONF_PREFIX)/bin/u-boot-mkimage \
		-A $(PTXCONF_ARCH) \
		-O Linux \
		-T ramdisk \
		-C gzip \
		-n $(PTXCONF_IMAGE_UIMAGE_NAME) \
		-d $(IMAGEDIR)/root.ext2.gz \
		$(IMAGEDIR)/uRamdisk
endif
ifdef PTXCONF_IMAGE_MKNBI
	PERL5LIB=$(PTXCONF_PREFIX)/usr/local/lib/mknbi \
		 $(PTXCONF_PREFIX)/usr/local/lib/mknbi/mknbi \
		--format=$(MKNBI_EXT) \
		--target=linux \
		--output=$(IMAGEDIR)/$(PTXCONF_PROJECT).$(MKNBI_EXT) \
		-a $(PTXCONF_IMAGE_MKNBI_APPEND) \
		$(MKNBI_KERNEL) \
		$(MKNBI_ROOTFS)
endif
	touch $@

# ----------------------------------------------------------------------------
# Simulation
# ----------------------------------------------------------------------------

uml_cmdline=
ifdef PTXCONF_KERNEL_HOST_ROOT_HOSTFS
uml_cmdline += root=/dev/root rootflags=$(ROOTDIR) rootfstype=hostfs
endif
ifdef PTXCONF_KERNEL_HOST_CONSOLE_STDSERIAL
uml_cmdline += ssl0=fd:0,fd:1
endif
#uml_cmdline += eth0=slirp
uml_cmdline += $(PTXCONF_KERNEL_HOST_CMDLINE)

run: world
	@$(call targetinfo, "Run Simulation")
ifdef NATIVE
	@echo "starting Linux..."
	@echo
	@$(ROOTDIR)/boot/linux $(call remove_quotes,$(uml_cmdline))
else
	@echo
	@echo "cannot run simulation if not in NATIVE=1 mode"
	@echo
	@exit 1
endif

# ----------------------------------------------------------------------------
# Configuration system
# ----------------------------------------------------------------------------

# FIXME: move this to a saner place, now that lxdialog is a host tool

ptx_lxdialog:
	@echo -e "#include \"ncurses.h\"\nint main(void){}" | gcc -E - > /dev/null; 	\
	if [ "$$?" = "1" ]; then							\
		echo;									\
		echo "Error: you don't seem to have ncurses.h; this probably means"; 	\
		echo "       that you'll have to install some ncurses-devel packet";	\
		echo "       from your distribution.";					\
		echo;									\
		exit 1;									\
	fi

before_config:
	@echo "checking \$$PTXDIST_WORKSPACE/config"
	@if [ -n "$(OUTOFTREE)" ] && [ ! -d "$(PTXDIST_WORKSPACE)/config/setup" ]; then 	\
		echo "out-of-tree build, creating setup dir";				\
		rm -fr $(PTXDIST_WORKSPACE)/config/setup;				\
		mkdir -p $(PTXDIST_WORKSPACE)/config; 					\
		cp -a $(PTXDIST_TOPDIR)/config/setup $(PTXDIST_WORKSPACE)/config; 	\
		for i in $(PTXDIST_TOPDIR)/config/uClibc* $(PTXDIST_TOPDIR)/config/busybox*; do \
			ln -sf $$i $(PTXDIST_WORKSPACE)/config/`basename $$i`; 		\
		done; 									\
	fi	
	@echo "checking \$$PTXDIST_WORKSPACE/rules"
	@[ -e "$(PTXDIST_WORKSPACE)/rules" ]   || ln -sf $(PTXDIST_TOPDIR)/rules   $(PTXDIST_WORKSPACE)/rules

menuconfig: before_config $(STATEDIR)/host-lxdialog.install $(STATEDIR)/host-kconfig.install
	$(call findout_config)
	cd $(PTXDIST_WORKSPACE) && $(PTXDIST_WORKSPACE)/scripts/kconfig/mconf $(MENU)
	# automatic oldconfig for consistent .config files 
	@if [ -f $(PTXDIST_WORKSPACE)/.config ]; then cd $(PTXDIST_WORKSPACE) && make oldconfig; fi

xconfig: before_config $(STATEDIR)/host-kconfig.install
	$(call findout_config)
	cd $(PTXDIST_WORKSPACE) && $(PTXDIST_WORKSPACE)/scripts/kconfig/qconf $(MENU)
	# automatic oldconfig for consistent .config files 
	cd $(PTXDIST_WORKSPACE) && make oldconfig

gconfig: before_config $(STATEDIR)/host-kconfig.install
	$(call findout_config)
	LD_LIBRARY_PATH=$(PTXDIST_TOPDIR)/scripts/kconfig cd $(PTXDIST_WORKSPACE) && $(PTXDIST_WORKSPACE)/scripts/kconfig/gconf $(MENU)
	# automatic oldconfig for consistent .config files 
	cd $(PTXDIST_WORKSPACE) && make oldconfig

oldconfig: before_config $(STATEDIR)/host-kconfig.install
	$(call findout_config)
	cd $(PTXDIST_WORKSPACE) && $(PTXDIST_WORKSPACE)/scripts/kconfig/conf -o $(MENU)

configdeps: before_config $(STATEDIR)/host-kconfig.install
	@$(call findout_config)
	@echo
	@echo "generating dependencies from kconfig..."
	@mkdir -p $(IMAGEDIR)
	@cd $(PTXDIST_WORKSPACE) && \
		yes "" | $(PTXDIST_WORKSPACE)/scripts/kconfig/conf -O $(MENU) | grep -e "^DEP:.*:.*" \
			2> /dev/null > $(IMAGEDIR)/configdeps
	@echo "$(IMAGEDIR)/configdeps"
	@echo

setup: before_config $(STATEDIR)/host-lxdialog.install $(STATEDIR)/host-kconfig.install
	@rm -f $(PTXDIST_WORKSPACE)/config/setup/.config
	@ln -sf $(PTXDIST_WORKSPACE)/scripts $(PTXDIST_WORKSPACE)/config/setup/scripts
	@if [ -f $(HOME)/.ptxdistrc ]; then 					\
		echo "using \$$HOME/.ptxdistrc"; 				\
		cp $(HOME)/.ptxdistrc $(PTXDIST_WORKSPACE)/config/setup/.config;\
	fi
	@(cd $(PTXDIST_WORKSPACE)/config/setup && $(PTXDIST_WORKSPACE)/scripts/kconfig/mconf Kconfig)
	@echo "cleaning up after setup..."
	@for i in .tmpconfig.h .config.old .config.cmd; do			\
		rm -f $(PTXDIST_WORKSPACE)/config/setup/$$i; 			\
	done
	@if [ -f $(PTXDIST_WORKSPACE)/config/setup/.config ]; then 		\
		echo "copying new .ptxdistrc to $(HOME)...";			\
		cp $(PTXDIST_WORKSPACE)/config/setup/.config $(HOME)/.ptxdistrc;\
		echo "done.";							\
	fi

# ----------------------------------------------------------------------------
# Config Targets
# ----------------------------------------------------------------------------

%_config:
	@echo; \
	echo "[Searching for Config File:]"; 						\
	CFG="`find $(PROJECTDIRS) -name $(subst _config,.ptxconfig,$@) 2> /dev/null`";	\
	if [ `echo $$CFG | wc -w` -gt 1 ]; then						\
		echo "ERROR: more than one config file found:"; 		\
		echo $$CFG; echo; 						\
		exit 1;								\
	fi;									\
	if [ -n "$$CFG" ]; then 						\
		echo "config file: \"$$CFG\""; 					\
		cp $$CFG $(PTXDIST_WORKSPACE)/.config; 				\
		echo "workspace:   \"$(PTXDIST_WORKSPACE)\"";			\
	else 									\
		echo "could not find config file \"$@\""; 			\
		exit 1;								\
	fi; 									\
	echo

# ----------------------------------------------------------------------------
# Test
# ----------------------------------------------------------------------------

config-test: 
	@for i in `find $(PROJECTDIRS) -name "*.ptxconfig"`; do 	\
		OUT=`basename $$i`;					\
		$(call targetinfo,$$OUT);				\
		cp $$i .config;						\
		make oldconfig;						\
		cp .config $$i;						\
	done

default_crosstool=/opt/crosstool-0.38

compile-test:
	cd $(PTXDIST_WORKSPACE);						\
	rm -f COMPILE-TEST;						\
	echo "Automatic Compilation Test" >> COMPILE-TEST;		\
	echo "--------------------------" >> COMPILE-TEST;		\
	echo >> COMPILE-TEST;						\
	echo start: `date` >> COMPILE-TEST;				\
	echo >> COMPILE-TEST;						\
	scripts/compile-test $(default_crosstool)/gcc-2.95.3-glibc-2.2.5/i586-unknown-linux-gnu/bin frako             COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.4.4-glibc-2.3.5/i586-unknown-linux-gnu/bin abbcc-viac3        COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.4.4-glibc-2.3.5/i586-unknown-linux-gnu/bin i586-generic-glibc COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.4.4-glibc-2.3.5/i586-unknown-linux-gnu/bin visbox             COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.4.4-glibc-2.3.5/i586-unknown-linux-gnu/bin rayonic-i586       COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-2.95.3-glibc-2.2.5/arm-softfloat-linux-gnu/bin innokom-2.4-2.95 COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.3.3-glibc-2.3.2/arm-softfloat-linux-gnu/bin innokom-2.4-3.3.3 COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.3.3-glibc-2.3.2/arm-softfloat-linux-gnu/bin mx1fs2            COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.3.3-glibc-2.3.2/arm-softfloat-linux-gnu/bin pii_nge           COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.3.3-glibc-2.3.2/arm-softfloat-linux-gnu/bin ssv_pnp2110_eva1  COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.4.1-glibc-2.3.3/powerpc-604-linux-gnu/bin eb8245              COMPILE-TEST;\
	scripts/compile-test $(default_crosstool)/gcc-3.2.3-glibc-2.2.5/powerpc-405-linux-gnu/bin cameron-efco        COMPILE-TEST;\
	echo >> COMPILE-TEST;						\
	echo stop: `date` >> COMPILE-TEST;				\
	echo >> COMPILE-TEST;

cuckoo-test: world
	@scripts/cuckoo-test $(PTXCONF_ARCH) $(ROOTDIR) $(PTXCONF_COMPILER_PREFIX)

ipkg-test: world
	@IMAGES=$(IMAGEDIR) ROOT=$(ROOTDIR) IPKG=$(PTXCONF_PREFIX)/bin/ipkg-cl  scripts/ipkg-test

# ----------------------------------------------------------------------------

toolchains:
	cd $(PTXDIST_WORKSPACE); 					\
	rm -f TOOLCHAINS;						\
	echo "Automatic Toolchain Compilation" >> TOOLCHAINS;		\
	echo "--------------------------" >> TOOLCHAINS;		\
	echo >> TOOLCHAINS;						\
	echo start: `date` >> TOOLCHAINS;				\
	echo >> TOOLCHAINS;						\
	scripts/compile-test /usr/bin toolchain_arm-softfloat-linux-gnu-2.95.3_glibc_2.2.5     TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_arm-softfloat-linux-gnu-3.3.3_glibc_2.3.2      TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_arm-softfloat-linux-gnu-3.4.4_glibc_2.3.5      TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_arm-softfloat-linux-uclibc-3.3.3_uClibc-0.9.27 TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_i586-unknown-linux-gnu-2.95.3_glibc-2.2.5      TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_i586-unknown-linux-gnu-3.4.2_glibc-2.3.3       TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_i586-unknown-linux-gnu-3.4.4_glibc-2.3.5       TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_i586-unknown-linux-uclibc-3.3.3_uClibc-0.9.27  TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_m68k-unknown-linux-uclibc-3.3.3_uClibc-0.9.27  TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_powerpc-405-linux-gnu-3.2.3_glibc-2.2.5        TOOLCHAINS;\
	scripts/compile-test /usr/bin toolchain_powerpc-604-linux-gnu-3.4.1_glibc-2.3.3        TOOLCHAINS;\
	echo >> TOOLCHAINS;						\
	echo stop: `date` >> TOOLCHAINS;				\
	echo >> TOOLCHAINS;

# ----------------------------------------------------------------------------

qa:
	@cd $(PTXDIST_WORKSPACE);					\
	rm -f QA.log;							\
	echo "Automatic Internal QA Check" >> QA.log;			\
	echo start: `date` >> QA.log;                    		\
	scripts/qa/master >> QA.log 2>&1;				\
	echo stop: `date` >> QA.log;                                    \
	echo >> QA.log;
	@cat QA.log;

# ----------------------------------------------------------------------------
# Cleaning
# ----------------------------------------------------------------------------

imagesclean:
	@echo -n "cleaning images dir.............. "
	@rm -fr $(IMAGEDIR)
	@rm -f $(STATEDIR)/images
	@echo "done."
	@echo

rootclean: imagesclean
	@echo -n "cleaning root dir................ "
	@rm -fr $(ROOTDIR)
	@echo "done."
	@echo -n "cleaning state/*.targetinstall... "
	@rm -f $(STATEDIR)/*.targetinstall
	@echo "done."	
	@echo -n "cleaning permissions............. "
	@rm -f $(IMAGEDIR)/permissions
	@echo "done."
	@echo

projectclean: rootclean
	@echo -n "cleaning state dir............... "
	@for i in $(notdir $(wildcard $(STATEDIR)/*)); do 		\
		[ -n "`echo \"$$i\" | grep host-`" ] || rm -fr $(STATEDIR)/$$i;\
	done
	@echo "done."
	@echo -n "cleaning host build dir.......... "
	@for i in $(wildcard $(BUILDDIR)/*); do 			\
		echo -n $$i; 						\
		rm -rf $$i; 						\
		echo; echo -n "                                  ";	\
	done
	@rm -fr $(BUILDDIR)
	@echo "done."
	@echo -n "cleaning dependency tree ........ "
	@rm -f $(DEP_OUTPUT) $(DEP_TREE_PS) $(DEP_TREE_A4_PS)
	@echo "done."
	@if [ -d $(PTXDIST_TOPDIR)/Documentation/manual ]; then				\
		echo -n "cleaning manual.................. ";				\
		make -C $(PTXDIST_TOPDIR)/Documentation/manual clean > /dev/null;	\
		echo "done.";								\
	fi;
	@echo

clean: projectclean
	@echo -n "cleaning build-host dir.......... "
	@for i in $(wildcard $(STATEDIR)/*); do rm -rf $$i; done
	@for i in $(wildcard $(HOST_BUILDDIR)/*); do 			\
		echo -n $$i; 						\
		rm -rf $$i; 						\
		echo; echo -n "                                  ";	\
	done
	@rm -fr $(HOST_BUILDDIR)
	@echo "done."
	@echo -n "cleaning build-cross dir......... "
	@for i in $(wildcard $(CROSS_BUILDDIR)/*); do 			\
		echo -n $$i; 						\
		rm -rf $$i; 						\
		echo; echo -n "                                  ";	\
	done
	@rm -fr $(CROSS_BUILDDIR)
	@echo "done."
	@echo -n "cleaning scripts dir............. "
	@if [ -n "$(OUTOFTREE)" ]; then 				\
		rm -fr $(PTXDIST_WORKSPACE)/scripts; 			\
	else								\
		make -s -C $(PTXDIST_WORKSPACE)/scripts/kconfig clean;	\
		rm -f $(PTXDIST_WORKSPACE)/scripts/lxdialog/lxdialog;	\
	fi
	@echo "done."
	@echo

distclean: clean
	@echo -n "cleaning logfile................. "
	@rm -f logfile* 
	@echo "done."
	@echo -n "cleaning .config................. "
	@cd $(PTXDIST_WORKSPACE) && rm -f .config* .tmp*
	@cd $(PTXDIST_WORKSPACE) && rm -f config/setup/scripts config/setup/.config scripts/scripts
	@echo "done."
	@echo -n "cleaning logs.................... "
	@rm -fr $(PTXDIST_WORKSPACE)/logs/root-orig.txt $(PTXDIST_WORKSPACE)/logs/root-ipkg.txt $(PTXDIST_WORKSPACE)/logs/root.diff
	@echo "done."
	@if [ -n "$(OUTOFTREE)" ]; then 				\
		rm -f $(PTXDIST_WORKSPACE)/config;			\
		rm -f $(PTXDIST_WORKSPACE)/rules;			\
		rm -fr $(PTXDIST_WORKSPACE)/state;			\
	fi
	@echo

# ----------------------------------------------------------------------------
# SVN Targets
# ----------------------------------------------------------------------------

svn-up:
	@$(call targetinfo, Updating in Toplevel)
	@cd $(PTXDIST_WORKSPACE) && svn update
	@if [ -d "$(PROJECTDIR)" ]; then				\
		$(call targetinfo, Updating in PROJECTDIR);		\
		cd $(PROJECTDIR);					\
		[ -d .svn ] && svn update; 				\
	fi;
	@echo "done."

svn-stat:
	@$(call targetinfo, svn stat in Toplevel)
	@cd $(PTXDIST_WORKSPACE) && svn stat
	@if [ -d "$(PROJECTDIR)" ]; then				\
		$(call targetinfo, svn stat in PROJECTDIR);		\
		cd $(PROJECTDIR);					\
		[ -d .svn ] && svn stat; 				\
	fi;
	@echo "done."

# ----------------------------------------------------------------------------
# Misc other targets
# ----------------------------------------------------------------------------

archive:  
	@echo
	@echo -n "packaging additional sources ...... "
	scripts/collect_sources.sh $(PTXDIST_TOPDIR) $(shell basename $(PTXDIST_TOPDIR))

archive-toolchain: virtual-xchain_install
	$(TAR) -C $(PTXCONF_PREFIX)/.. -jcvf $(PTXDIST_TOPDIR)/$(PTXCONF_GNU_TARGET).tar.bz2 \
		$(shell basename $(PTXCONF_PREFIX))

.PHONY: projects
projects:
	@for dir in $(call remove_quotes,$(PROJECTDIRS)); do 						\
		(cd $$dir); 										\
		if [ "$$?" != "0" ]; then								\
			echo;										\
			echo "Error: PTXCONF_SETUP_PROJECTDIR macros point to something which";		\
			echo "       is no directory. Check your .ptxdistrc file. ";			\
			echo;										\
			echo "Directory: $$dir";							\
			echo;										\
			exit 1;										\
		fi											\
	done
	@echo
	@echo "---------------------- Available PTXdist Projects: ----------------------------"
	@echo
	@for i in `find $(PROJECTDIRS) -name "*.ptxconfig"`; do 					\
		basename `echo $$i | perl -p -e "s/.ptxconfig/_config/g"`; 				\
	done | sort 
	@echo
	@echo "-------------------------------------------------------------------------------"
	@echo

configs:
	@echo
	@echo "Please use 'make projects' instead of 'make configs'. Thanks."
	@echo

%_recompile:
	@rm -f $(STATEDIR)/$*.compile
	@make -C $(PTXDIST_WORKSPACE) $*_compile

print-%:
	@echo "$* is \"$($*)\""

# ----------------------------------------------------------------------------
# Autogenerate Dependencies
# ----------------------------------------------------------------------------
#
# For all packages: 
#
# - each prepare stage depends on all prerequisites' install stage
# - each targetinstall stage depends on all pre.'s targetinstall stages
#

deps_apache2 = expat glibc_librt

define autogen_deps_prepare
$(1)_test_prepare_deps: $(foreach dep,$(deps_$(1)),$(STATEDIR)/$(dep).install)
endef

$(foreach pkg,$(ALL_PACKAGES),$(eval $(call autogen_deps_prepare,$(pkg))))

define autogen_deps_targetinstall
$(1)_test_targetinstall_deps: $(foreach dep,$(deps_$(1)),$(STATEDIR)/$(dep).targetinstall)
endef

$(foreach pkg,$(ALL_PACKAGES),$(eval $(call autogen_deps_targetinstall,$(pkg))))

.PHONY: dep_output_clean dep_tree dep_world
# vim600:set foldmethod=marker:
