################################################################################
#
# mt8127-wmt
#
################################################################################

MT8127_WMT_VERSION = $(TB3_BRA_VERSION)
MT8127_WMT_SITE = $(TB3_BRA_SITE)
MT8127_WMT_SOURCE = $(TB3_BRA_SOURCE)
MT8127_WMT_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_WMT_LICENSE = GPL-2.0
MT8127_WMT_MODULE_SUBDIRS = wmt
MT8127_WMT_DEPENDENCIES = mt8127-btif mt8127-consys
MT8127_WMT_MODULE_MAKE_OPTS = KBUILD_EXTRA_SYMBOLS="$(MT8127_BTIF_BUILDDIR)/btif/Module.symvers $(MT8127_CONSYS_BUILDDIR)/consys/Module.symvers"

define MT8127_WMT_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_WMT,buildroot-external/package/mt8127-connectivity/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
