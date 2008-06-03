# -*-makefile-*-
# $Id: template 6655 2007-01-02 12:55:21Z rsc $
#
# Copyright (C) 2007 by Bjoern Buerger <b.buerger@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_SUN_JAVA6_JRE) += sun-java6-jre

#
# Paths and names
#
SUN_JAVA6_JRE_VERSION		:= 1.6.0.02
#SUN_JAVA6_JRE_SUFFIX		:= nonexistant

SUN_JAVA6_JRE			:= jre-6u2-linux-i586
SUN_JAVA6_JRE_SOURCE		:= $(SRCDIR)/$(SUN_JAVA6_JRE).bin
SUN_JAVA6_JRE_URL		:= http://javadl.sun.com/webapps/download/AutoDL?BundleId=11284
SUN_JAVA6_JRE_DIR		:= $(BUILDDIR)/$(SUN_JAVA6_JRE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sun-java6-jre_get: $(STATEDIR)/sun-java6-jre.get

$(STATEDIR)/sun-java6-jre.get: $(sun-java6-jre_get_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

$(SUN_JAVA6_JRE_SOURCE):
	@$(call targetinfo, $@)
	$(WGET) --output-document=$(SUN_JAVA6_JRE_SOURCE) $(SUN_JAVA6_JRE_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sun-java6-jre_extract: $(STATEDIR)/sun-java6-jre.extract

$(STATEDIR)/sun-java6-jre.extract: $(sun-java6-jre_extract_deps_default)
	@$(call targetinfo, $@)
	@$(call clean, $(SUN_JAVA6_JRE_DIR))
	magic(){ sh $(SUN_JAVA6_JRE_SOURCE) ; };						\
	[ -d $(SUN_JAVA6_JRE_DIR) ] || $(MKDIR) -p $(SUN_JAVA6_JRE_DIR);			\
	cd $(SUN_JAVA6_JRE_DIR)	; 								\
	case $$? in										\
	(0) 											\
		echo "extracting java shell archive (pwd is `pwd`)";				\
		echo "$(PTXCONF_SUN_JAVA6_JRE_LICENSE_ACCEPT_STRING)" | magic ;			\
	;;											\
	(*)	echo "an error occurred"; exit 1 ;						\
	;;											\
	esac
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sun-java6-jre_prepare: $(STATEDIR)/sun-java6-jre.prepare

SUN_JAVA6_JRE_PATH	:= PATH=$(CROSS_PATH)
SUN_JAVA6_JRE_ENV	:= $(CROSS_ENV)

#
# autoconf
#
SUN_JAVA6_JRE_AUTOCONF := $(CROSS_AUTOCONF_USR)

$(STATEDIR)/sun-java6-jre.prepare: $(sun-java6-jre_prepare_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sun-java6-jre_compile: $(STATEDIR)/sun-java6-jre.compile

$(STATEDIR)/sun-java6-jre.compile: $(sun-java6-jre_compile_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sun-java6-jre_install: $(STATEDIR)/sun-java6-jre.install

$(STATEDIR)/sun-java6-jre.install: $(sun-java6-jre_install_deps_default)
	@$(call targetinfo, $@)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sun-java6-jre_targetinstall: $(STATEDIR)/sun-java6-jre.targetinstall

$(STATEDIR)/sun-java6-jre.targetinstall: $(sun-java6-jre_targetinstall_deps_default)
	@$(call targetinfo, $@)

	@$(call install_init, sun-java6-jre)
	@$(call install_fixup, sun-java6-jre,PACKAGE,sun-java6-jre)
	@$(call install_fixup, sun-java6-jre,PRIORITY,optional)
	@$(call install_fixup, sun-java6-jre,VERSION,$(SUN_JAVA6_JRE_VERSION))
	@$(call install_fixup, sun-java6-jre,SECTION,base)
	@$(call install_fixup, sun-java6-jre,AUTHOR,"autogenerated from sun package")
	@$(call install_fixup, sun-java6-jre,DEPENDS,)
	@$(call install_fixup, sun-java6-jre,DESCRIPTION,missing)

	# derived from ancillary file installation
	 @uid=$$(id -u); gid=$$(id -g);	\
	  (cd $(SUN_JAVA6_JRE_DIR); find jre* | grep -v "\.svn")													\
	| while read i; do																		\
		read fuid fgid fperm < <(stat -c "%u %g %a" $(SUN_JAVA6_JRE_DIR)/$$i);											\
		if [ $$fuid -eq $$uid ]; then fuid=0; fi;														\
		if [ $$fgid -eq $$gid ]; then fgid=0; fi;														\
		ft=$$( LANG=C stat -c %F $(SUN_JAVA6_JRE_DIR)/$$i );													\
		case "$$ft" in																		\
		"regular file")																		\
			$(call install_copy, sun-java6-jre, $$fuid, $$fgid, $$fperm, $(SUN_JAVA6_JRE_DIR)/$$i, $(PTXCONF_SUN_JAVA6_JRE_TARGET_PREFIX)/$$i);; 		\
		"regular empty file")																	\
			$(call install_copy, sun-java6-jre, $$fuid, $$fgid, $$fperm, ${PTXDIST_WORKSPACE}/projectroot/empty, $(PTXCONF_SUN_JAVA6_JRE_TARGET_PREFIX)/$$i);; \
		"directory")																		\
			$(call install_copy, sun-java6-jre, $$fuid, $$fgid, $$fperm, $(PTXCONF_SUN_JAVA6_JRE_TARGET_PREFIX)/$$i);; 					\
		"symbolic link")																	\
			target=$$( readlink $(SUN_JAVA6_JRE_DIR)/$$i );													\
			$(call install_link, sun-java6-jre, $$target, $(PTXCONF_SUN_JAVA6_JRE_TARGET_PREFIX)/$$i);;							\
		*)																			\
			echo "ERROR: File '$$ft' type of '$$i' not supported";												\
			exit 1;;																	\
		esac ;																			\
	done

	@$(call install_finish, sun-java6-jre)
	@$(call touch, $@)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sun-java6-jre_clean:
	rm -rf $(STATEDIR)/sun-java6-jre.*
	rm -rf $(PKGDIR)/sun-java6-jre_*
	rm -rf $(SUN_JAVA6_JRE_DIR)

# vim: syntax=make
