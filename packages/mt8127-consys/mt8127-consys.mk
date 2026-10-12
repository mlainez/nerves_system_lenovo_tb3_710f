################################################################################
#
# mt8127-consys
#
################################################################################

MT8127_CONSYS_VERSION = $(TB3_BRA_VERSION)
MT8127_CONSYS_SITE = $(TB3_BRA_SITE)
MT8127_CONSYS_SOURCE = $(TB3_BRA_SOURCE)
MT8127_CONSYS_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_CONSYS_LICENSE = GPL-2.0
MT8127_CONSYS_MODULE_SUBDIRS = consys

define MT8127_CONSYS_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_CONSYS,buildroot-external/package/mt8127-connectivity/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
