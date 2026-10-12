################################################################################
#
# mt8127-camera
#
################################################################################

MT8127_CAMERA_VERSION = $(TB3_BRA_VERSION)
MT8127_CAMERA_SITE = $(TB3_BRA_SITE)
MT8127_CAMERA_SOURCE = $(TB3_BRA_SOURCE)
MT8127_CAMERA_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
MT8127_CAMERA_LICENSE = GPL-2.0
MT8127_CAMERA_MODULE_SUBDIRS = sensors cam

define MT8127_CAMERA_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,MT8127_CAMERA,buildroot-external/package/mt8127-camera/src)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
