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
PACKAGES-$(PTXCONF_XORG_LIB_XRANDR) += xorg-lib-xrandr

#
# Paths and names
#
XORG_LIB_XRANDR_VERSION	:= 1.3.1
XORG_LIB_XRANDR_MD5	:= 7785c3f7cff2735c94657e8f87ed8ad3
XORG_LIB_XRANDR		:= libXrandr-$(XORG_LIB_XRANDR_VERSION)
XORG_LIB_XRANDR_SUFFIX	:= tar.bz2
XORG_LIB_XRANDR_URL	:= $(PTXCONF_SETUP_XORGMIRROR)/individual/lib/$(XORG_LIB_XRANDR).$(XORG_LIB_XRANDR_SUFFIX)
XORG_LIB_XRANDR_SOURCE	:= $(SRCDIR)/$(XORG_LIB_XRANDR).$(XORG_LIB_XRANDR_SUFFIX)
XORG_LIB_XRANDR_DIR	:= $(BUILDDIR)/$(XORG_LIB_XRANDR)


# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(XORG_LIB_XRANDR_SOURCE):
	@$(call targetinfo)
	@$(call get, XORG_LIB_XRANDR)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

XORG_LIB_XRANDR_PATH	:= PATH=$(CROSS_PATH)
XORG_LIB_XRANDR_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XORG_LIB_XRANDR_AUTOCONF := $(CROSS_AUTOCONF_USR) \
	--disable-malloc0returnsnull

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/xorg-lib-xrandr.targetinstall:
	@$(call targetinfo)

	@$(call install_init, xorg-lib-xrandr)
	@$(call install_fixup, xorg-lib-xrandr,PRIORITY,optional)
	@$(call install_fixup, xorg-lib-xrandr,SECTION,base)
	@$(call install_fixup, xorg-lib-xrandr,AUTHOR,"Erwin Rol <ero@pengutronix.de>")
	@$(call install_fixup, xorg-lib-xrandr,DESCRIPTION,missing)

	@$(call install_lib, xorg-lib-xrandr, 0, 0, 0644, libXrandr)

	@$(call install_finish, xorg-lib-xrandr)

	@$(call touch)

# vim: syntax=make
