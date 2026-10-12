################################################################################
#
# mt8127-btif
#
################################################################################

MT8127_BTIF_VERSION = $(TB3_BRA_VERSION)
MT8127_BTIF_SITE = $(TB3_BRA_SITE)
MT8127_BTIF_SOURCE = $(TB3_BRA_SOURCE)
MT8127_BTIF_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_BTIF_LICENSE = GPL-2.0
MT8127_BTIF_MODULE_SUBDIRS = btif

define MT8127_BTIF_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_BTIF,buildroot-external/package/mt8127-connectivity/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
