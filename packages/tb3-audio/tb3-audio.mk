################################################################################
#
# tb3-audio
#
################################################################################

TB3_AUDIO_VERSION = $(TB3_BRA_VERSION)
TB3_AUDIO_SITE = $(TB3_BRA_SITE)
TB3_AUDIO_SOURCE = $(TB3_BRA_SOURCE)
TB3_AUDIO_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
TB3_AUDIO_LICENSE = MIT
TB3_AUDIO_DEPENDENCIES = alsa-utils

define TB3_AUDIO_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,TB3_AUDIO,buildroot-external/package/tb3-audio)
endef

# Only the mixer state: the Buildroot board's S30alsa init script has no
# place in Nerves, where the application restores the state.
define TB3_AUDIO_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/asound.state $(TARGET_DIR)/var/lib/alsa/asound.state
endef

$(eval $(generic-package))
