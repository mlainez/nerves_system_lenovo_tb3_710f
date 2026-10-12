################################################################################
#
# mt8127-wlan
#
################################################################################

MT8127_WLAN_VERSION = $(TB3_BRA_VERSION)
MT8127_WLAN_SITE = $(TB3_BRA_SITE)
MT8127_WLAN_SOURCE = $(TB3_BRA_SOURCE)
MT8127_WLAN_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_WLAN_LICENSE = GPL-2.0
MT8127_WLAN_MODULE_SUBDIRS = wlan
MT8127_WLAN_DEPENDENCIES = mt8127-wmt mt8127-consys
MT8127_WLAN_MODULE_MAKE_OPTS = KBUILD_EXTRA_SYMBOLS="$(MT8127_WMT_BUILDDIR)/wmt/Module.symvers $(MT8127_CONSYS_BUILDDIR)/consys/Module.symvers"

define MT8127_WLAN_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_WLAN,buildroot-external/package/mt8127-connectivity/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
