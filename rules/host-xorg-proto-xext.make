# -*-makefile-*-
#
# Copyright (C) 2007 by Robert Schwebel
#           (C) 2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
HOST_PACKAGES-$(PTXCONF_HOST_XORG_PROTO_XEXT) += host-xorg-proto-xext

#
# Paths and names
#
HOST_XORG_PROTO_XEXT		= $(XORG_PROTO_XEXT)
HOST_XORG_PROTO_XEXT_DIR	= $(HOST_BUILDDIR)/$(HOST_XORG_PROTO_XEXT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(STATEDIR)/host-xorg-proto-xext.get: $(STATEDIR)/xorg-proto-xext.get
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

HOST_XORG_PROTO_XEXT_PATH	:= PATH=$(HOST_PATH)
HOST_XORG_PROTO_XEXT_ENV 	:= $(HOST_ENV)

#
# autoconf
#
HOST_XORG_PROTO_XEXT_AUTOCONF	:= $(HOST_AUTOCONF)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-xorg-proto-xext_clean:
	rm -rf $(STATEDIR)/host-xorg-proto-xext.*
	rm -rf $(HOST_XORG_PROTO_XEXT_DIR)

# vim: syntax=make
