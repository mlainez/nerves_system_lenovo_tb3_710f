################################################################################
#
# tb3-tools
#
################################################################################

TB3_TOOLS_VERSION = $(TB3_BRA_VERSION)
TB3_TOOLS_SITE = $(TB3_BRA_SITE)
TB3_TOOLS_SOURCE = $(TB3_BRA_SOURCE)
TB3_TOOLS_DL_SUBDIR = $(TB3_BRA_DL_SUBDIR)
TB3_TOOLS_LICENSE = MIT

define TB3_TOOLS_EXTRACT_CMDS
	$(call TB3_BRA_EXTRACT,TB3_TOOLS,buildroot-external/package/tb3-tools)
endef

define TB3_TOOLS_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(@D)/tb3-pmic.c -o $(@D)/tb3-pmic
endef

# reboot-mode sets the PMIC RTC bit LK reads and reboots at once, without
# erlinit's orderly shutdown.
define TB3_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/tb3-pmic $(TARGET_DIR)/usr/sbin/tb3-pmic
	printf '#!/bin/sh\nexec /usr/sbin/tb3-pmic reboot-mode "$$@"\n' > $(TARGET_DIR)/usr/sbin/reboot-mode
	chmod 755 $(TARGET_DIR)/usr/sbin/reboot-mode
endef

$(eval $(generic-package))
