# -*-makefile-*-
#
# Copyright (C) 2006 by Erwin Rol
#           (C) 2009 by Robert Schwebel
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
PACKAGES-$(PTXCONF_XORG_PROTO_RECORD) += xorg-proto-record

#
# Paths and names
#
XORG_PROTO_RECORD_VERSION	:= 1.14.1
XORG_PROTO_RECORD_MD5		:= 24541a30b399213def35f48efd926c63
XORG_PROTO_RECORD		:= recordproto-$(XORG_PROTO_RECORD_VERSION)
XORG_PROTO_RECORD_SUFFIX	:= tar.bz2
XORG_PROTO_RECORD_URL		:= $(PTXCONF_SETUP_XORGMIRROR)/individual/proto/$(XORG_PROTO_RECORD).$(XORG_PROTO_RECORD_SUFFIX)
XORG_PROTO_RECORD_SOURCE	:= $(SRCDIR)/$(XORG_PROTO_RECORD).$(XORG_PROTO_RECORD_SUFFIX)
XORG_PROTO_RECORD_DIR		:= $(BUILDDIR)/$(XORG_PROTO_RECORD)


# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(XORG_PROTO_RECORD_SOURCE):
	@$(call targetinfo)
	@$(call get, XORG_PROTO_RECORD)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

XORG_PROTO_RECORD_PATH	:= PATH=$(CROSS_PATH)
XORG_PROTO_RECORD_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
XORG_PROTO_RECORD_AUTOCONF := \
	$(CROSS_AUTOCONF_USR) \
	--disable-specs

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/xorg-proto-record.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# vim: syntax=make

