# -*-makefile-*-
#
# Copyright (C) 2006 by Erwin Rol
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_XORG_LIB_XT) += xorg-lib-xt

#
# Paths and names
#
XORG_LIB_XT_VERSION	:= 1.0.9
XORG_LIB_XT_MD5		:= 8a414f8f2327aaa616ca2dcac1f5d8c3
XORG_LIB_XT		:= libXt-$(XORG_LIB_XT_VERSION)
XORG_LIB_XT_SUFFIX	:= tar.bz2
XORG_LIB_XT_URL		:= $(PTXCONF_SETUP_XORGMIRROR)/individual/lib/$(XORG_LIB_XT).$(XORG_LIB_XT_SUFFIX)
XORG_LIB_XT_SOURCE	:= $(SRCDIR)/$(XORG_LIB_XT).$(XORG_LIB_XT_SUFFIX)
XORG_LIB_XT_DIR		:= $(BUILDDIR)/$(XORG_LIB_XT)


# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(XORG_LIB_XT_SOURCE):
	@$(call targetinfo)
	@$(call get, XORG_LIB_XT)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

XORG_LIB_XT_PATH	:= PATH=$(CROSS_PATH)
XORG_LIB_XT_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XORG_LIB_XT_AUTOCONF := \
	$(CROSS_AUTOCONF_USR) \
	--disable-malloc0returnsnull

ifdef PTXCONF_XORG_LIB_X11_XKB
XORG_LIB_XT_AUTOCONF += --enable-xkb
else
XORG_LIB_XT_AUTOCONF += --disable-xkb
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/xorg-lib-xt.targetinstall:
	@$(call targetinfo)

	@$(call install_init, xorg-lib-xt)
	@$(call install_fixup, xorg-lib-xt,PRIORITY,optional)
	@$(call install_fixup, xorg-lib-xt,SECTION,base)
	@$(call install_fixup, xorg-lib-xt,AUTHOR,"Erwin Rol <ero@pengutronix.de>")
	@$(call install_fixup, xorg-lib-xt,DESCRIPTION,missing)

	@$(call install_lib, xorg-lib-xt, 0, 0, 0644, libXt)

	@$(call install_finish, xorg-lib-xt)

	@$(call touch)

# vim: syntax=make
