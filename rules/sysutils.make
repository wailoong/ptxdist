# -*-makefile-*-
# $Id: sysutils.make,v 1.1 2004/07/01 16:06:26 rsc Exp $
#
# Copyright (C) 2004 by Robert Schwebel
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_SYSUTILS
PACKAGES += sysutils
endif

#
# Paths and names
#
SYSUTILS_VERSION	= 0.1.0
SYSUTILS		= sysutils-$(SYSUTILS_VERSION)
SYSUTILS_SUFFIX		= tar.gz
SYSUTILS_URL		= http://kernel.org/pub/linux/utils/kernel/hotplug/$(SYSUTILS).$(SYSUTILS_SUFFIX)
SYSUTILS_SOURCE		= $(SRCDIR)/$(SYSUTILS).$(SYSUTILS_SUFFIX)
SYSUTILS_DIR		= $(BUILDDIR)/$(SYSUTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sysutils_get: $(STATEDIR)/sysutils.get

sysutils_get_deps = $(SYSUTILS_SOURCE)

$(STATEDIR)/sysutils.get: $(sysutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SYSUTILS))
	touch $@

$(SYSUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SYSUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sysutils_extract: $(STATEDIR)/sysutils.extract

sysutils_extract_deps = $(STATEDIR)/sysutils.get

$(STATEDIR)/sysutils.extract: $(sysutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SYSUTILS_DIR))
	@$(call extract, $(SYSUTILS_SOURCE))
	@$(call patchin, $(SYSUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sysutils_prepare: $(STATEDIR)/sysutils.prepare

#
# dependencies
#
sysutils_prepare_deps = \
	$(STATEDIR)/sysutils.extract \
	$(STATEDIR)/virtual-xchain.install

SYSUTILS_PATH	=  PATH=$(CROSS_PATH)
SYSUTILS_ENV 	=  $(CROSS_ENV)

$(STATEDIR)/sysutils.prepare: $(sysutils_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sysutils_compile: $(STATEDIR)/sysutils.compile

sysutils_compile_deps = $(STATEDIR)/sysutils.prepare

$(STATEDIR)/sysutils.compile: $(sysutils_compile_deps)
	@$(call targetinfo, $@)
	cd $(SYSUTILS_DIR) && $(SYSUTILS_ENV) $(SYSUTILS_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sysutils_install: $(STATEDIR)/sysutils.install

$(STATEDIR)/sysutils.install: $(STATEDIR)/sysutils.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sysutils_targetinstall: $(STATEDIR)/sysutils.targetinstall

sysutils_targetinstall_deps = $(STATEDIR)/sysutils.compile

$(STATEDIR)/sysutils.targetinstall: $(sysutils_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_SYSUTILS_LSBUS
	cp $(SYSUTILS_DIR)/cmd/lsbus $(ROOTDIR)/usr/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/sbin/lsbus
endif
ifdef PTXCONF_SYSUTILS_SYSTOOL
	cp $(SYSUTILS_DIR)/cmd/systool $(ROOTDIR)/usr/sbin/
	$(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/sbin/systool
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sysutils_clean:
	rm -rf $(STATEDIR)/sysutils.*
	rm -rf $(SYSUTILS_DIR)

# vim: syntax=make
