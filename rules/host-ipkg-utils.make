# -*-makefile-*-
# $Id: template 2224 2005-01-20 15:19:18Z rsc $
#
# Copyright (C) 2005 by Robert Schwebel
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
HOST_PACKAGES-$(PTXCONF_HOST_IPKG_UTILS) += host-ipkg-utils

#
# Paths and names
#
HOST-IPKG-UTILS_VERSION	= 1.7
HOST-IPKG-UTILS		= ipkg-utils-$(HOST-IPKG-UTILS_VERSION)
HOST-IPKG-UTILS_SUFFIX	= tar.gz
HOST-IPKG-UTILS_URL		= ftp://ftp.handhelds.org/packages/ipkg-utils/$(HOST-IPKG-UTILS).$(HOST-IPKG-UTILS_SUFFIX)
HOST-IPKG-UTILS_SOURCE	= $(SRCDIR)/$(HOST-IPKG-UTILS).$(HOST-IPKG-UTILS_SUFFIX)
HOST-IPKG-UTILS_DIR		= $(HOST_BUILDDIR)/$(HOST-IPKG-UTILS)

-include $(call package_depfile)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

host-ipkg-utils_get: $(STATEDIR)/host-ipkg-utils.get

$(STATEDIR)/host-ipkg-utils.get: $(host-ipkg-utils_get_deps_default)
	@$(call targetinfo, $@)
	@$(call get_patches, $(HOST-IPKG-UTILS))
	@$(call touch, $@)

$(HOST-IPKG-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(HOST-IPKG-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

host-ipkg-utils_extract: $(STATEDIR)/host-ipkg-utils.extract

$(STATEDIR)/host-ipkg-utils.extract: $(host-ipkg-utils_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(HOST-IPKG-UTILS_DIR))
	@$(call extract, $(HOST-IPKG-UTILS_SOURCE), $(HOST_BUILDDIR))
	@$(call patchin, $(HOST-IPKG-UTILS), $(HOST-IPKG-UTILS_DIR))
	perl -i -p -e "s,^PREFIX=(.*),PREFIX=$(PTXCONF_HOST_PREFIX)/usr,g" \
		$(HOST-IPKG-UTILS_DIR)/Makefile
	perl -i -p -e "s,^	python setup.py install,	python setup.py install --prefix=$(PTXCONF_HOST_PREFIX)/usr,g" \
		$(HOST-IPKG-UTILS_DIR)/Makefile
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

host-ipkg-utils_prepare: $(STATEDIR)/host-ipkg-utils.prepare

HOST-IPKG-UTILS_PATH	=  PATH=$(CROSS_PATH)
HOST-IPKG-UTILS_ENV 	=  $(CROSS_ENV)

$(STATEDIR)/host-ipkg-utils.prepare: $(host-ipkg-utils_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

host-ipkg-utils_compile: $(STATEDIR)/host-ipkg-utils.compile

$(STATEDIR)/host-ipkg-utils.compile: $(host-ipkg-utils_compile_deps_default)
	@$(call targetinfo, $@)
	cd $(HOST-IPKG-UTILS_DIR) && $(HOST-IPKG-UTILS_ENV) $(HOST-IPKG-UTILS_PATH) make
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

host-ipkg-utils_install: $(STATEDIR)/host-ipkg-utils.install

$(STATEDIR)/host-ipkg-utils.install: $(host-ipkg-utils_install_deps_default)
	@$(call targetinfo, $@)
	mkdir -p $(PTXCONF_HOST_PREFIX)/usr/bin
	# ipkg.py is forgotten by MAKE_INSTALL, so we copy it manually
	# FIXME: this should probably be fixed upstream
	@$(call install, HOST-IPKG-UTILS,,h)
	mkdir -p $(PTXCONF_HOST_PREFIX)/usr/bin
	cp -f $(HOST-IPKG-UTILS_DIR)/ipkg.py $(PTXCONF_HOST_PREFIX)/usr/bin/
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

host-ipkg-utils_targetinstall: $(STATEDIR)/host-ipkg-utils.targetinstall

$(STATEDIR)/host-ipkg-utils.targetinstall: $(host-ipkg-utils_targetinstall_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-ipkg-utils_clean:
	rm -rf $(STATEDIR)/host-ipkg-utils.*
	rm -rf $(HOST-IPKG-UTILS_DIR)

# vim: syntax=make
