################################################################################
#
# mt8127-bt
#
################################################################################

MT8127_BT_VERSION = $(TB3_BRA_VERSION)
MT8127_BT_SITE = $(TB3_BRA_SITE)
MT8127_BT_SOURCE = $(TB3_BRA_SOURCE)
MT8127_BT_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_BT_LICENSE = GPL-2.0
MT8127_BT_MODULE_SUBDIRS = bt
MT8127_BT_DEPENDENCIES = mt8127-wmt
MT8127_BT_MODULE_MAKE_OPTS = KBUILD_EXTRA_SYMBOLS="$(MT8127_WMT_BUILDDIR)/wmt/Module.symvers"

define MT8127_BT_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_BT,buildroot-external/package/mt8127-connectivity/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
