################################################################################
#
# Unudhcpd
#
################################################################################

# Pinned to the latest tag instead of `main` so Buildroot's git
# checkout resolves a concrete commit; the `main` ref tripped up the
# pkg-generic fetch ("Commit 'main' does not exist in this repository").
UNUDHCPD_VERSION = 0.2.1
UNUDHCPD_SITE = https://gitlab.postmarketos.org/postmarketOS/unudhcpd.git
UNUDHCPD_SITE_METHOD = git
UNUDHCPD_LICENSE = GPL-3.0
UNUDHCPD_LICENSE_FILES = LICENSE

# Only the initramfs recovery shell runs it (citronics-initramfs copies it
# from the build directory). The Nerves rootfs has no DHCP server of its own:
# VintageNetDirect serves usb0.
UNUDHCPD_INSTALL_TARGET = NO

$(eval $(meson-package))
