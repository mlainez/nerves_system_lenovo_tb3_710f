################################################################################
#
# mt8127-fm
#
################################################################################

MT8127_FM_VERSION = $(TB3_BRA_VERSION)
MT8127_FM_SITE = $(TB3_BRA_SITE)
MT8127_FM_SOURCE = $(TB3_BRA_SOURCE)
MT8127_FM_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_FM_LICENSE = GPL-2.0
MT8127_FM_MODULE_SUBDIRS = fm
MT8127_FM_DEPENDENCIES = mt8127-wmt mt8127-consys
MT8127_FM_MODULE_MAKE_OPTS = KBUILD_EXTRA_SYMBOLS="$(MT8127_WMT_BUILDDIR)/wmt/Module.symvers $(MT8127_CONSYS_BUILDDIR)/consys/Module.symvers"

# The FM driver registers its own device and is not loaded by modalias: the
# application loads mtk_consys_fm when it wants the radio. Only the fm-radio
# tool is installed, not the Buildroot board's S36fmradio init script.
define MT8127_FM_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(@D)/tools/fm-radio.c -o $(@D)/tools/fm-radio
endef

define MT8127_FM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/tools/fm-radio $(TARGET_DIR)/usr/bin/fm-radio
endef

define MT8127_FM_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_FM,buildroot-external/package/mt8127-connectivity/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
