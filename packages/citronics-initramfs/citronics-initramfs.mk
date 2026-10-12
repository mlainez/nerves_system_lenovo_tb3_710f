################################################################################
#
# citronics-initramfs
#
# The early-boot initramfs, stored next to the kernel in each boot slot. It
# maps the Nerves partitions nested in the stock userdata partition with
# kpartx, mounts the active rootfs (nested partition 2, named by rootfs= on the
# command line) and switch_roots into erlinit. Its programs are copied out of
# the target tree, so they are the same builds the rootfs ships.
#
################################################################################

CITRONICS_INITRAMFS_VERSION = 6e058d7
CITRONICS_INITRAMFS_SITE = https://github.com/Citronics/initramfs.git
CITRONICS_INITRAMFS_SITE_METHOD = git
CITRONICS_INITRAMFS_LICENSE_FILES = LICENSE

CITRONICS_INITRAMFS_DEPENDENCIES = busybox unudhcpd multipath-tools parted linux

CITRONICS_INITRAMFS_STAGING = $(@D)/initramfs-root
CITRONICS_INITRAMFS_SRC_DIR = initramfs/usr/share/citronics-initramfs
CITRONICS_INITRAMFS_PKG_DIR = $(NERVES_DEFCONFIG_DIR)/packages/citronics-initramfs
# The non-BusyBox programs the init runs: kpartx maps the nested partitions,
# parted answers the upstream free-space check (resizing stays off: the
# application partition must not grow into the MTK BMT pool), unudhcpd serves
# the USB recovery network.
CITRONICS_BINARIES = busybox kpartx parted unudhcpd

KERNEL_VERSION = $(shell find $(TARGET_DIR)/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n1)

define CITRONICS_INITRAMFS_BUILD_CMDS
	true
endef

define CITRONICS_INITRAMFS_INSTALL_TARGET_CMDS
	rm -rf $(CITRONICS_INITRAMFS_STAGING)
	mkdir -p $(CITRONICS_INITRAMFS_STAGING)
	mkdir -p $(CITRONICS_INITRAMFS_STAGING)/{bin,sbin,usr/bin,usr/sbin,lib,etc,proc,sys,dev,tmp,var,run,mnt,root,sysroot}
	chmod 1777 $(CITRONICS_INITRAMFS_STAGING)/tmp
	chmod 1777 $(CITRONICS_INITRAMFS_STAGING)/run

	cp -aL $(@D)/$(CITRONICS_INITRAMFS_SRC_DIR)/* $(CITRONICS_INITRAMFS_STAGING)/
	mkdir -p $(CITRONICS_INITRAMFS_STAGING)/usr/share/deviceinfo
	cp -RaL $(CITRONICS_INITRAMFS_STAGING)/misc $(CITRONICS_INITRAMFS_STAGING)/usr/share/misc
	$(INSTALL) -D -m 0644 $(CITRONICS_INITRAMFS_PKG_DIR)/deviceinfo \
		$(CITRONICS_INITRAMFS_STAGING)/usr/share/deviceinfo/deviceinfo

	# Everything on the path to switch_root is built into the kernel.
	: > $(CITRONICS_INITRAMFS_STAGING)/lib/modules/initramfs.load
	mkdir -p $(CITRONICS_INITRAMFS_STAGING)/lib/modules/$(KERNEL_VERSION)
	while read -r modpath; do \
		case "$$modpath" in ""|\#*) continue;; esac; \
		src="$(TARGET_DIR)/lib/modules/$(KERNEL_VERSION)/$$modpath"; \
		dest="$(CITRONICS_INITRAMFS_STAGING)/lib/modules/$(KERNEL_VERSION)/$$modpath"; \
		if [ -f "$$src" ]; then \
			mkdir -p "$$(dirname "$$dest")"; \
			cp -aL "$$src" "$$dest"; \
		else \
			echo "citronics-initramfs: module $$modpath not in the target" >&2; \
			exit 1; \
		fi; \
	done < $(CITRONICS_INITRAMFS_PKG_DIR)/modules

	for bin in $(CITRONICS_BINARIES); do \
		src=""; \
		for dir in usr/sbin sbin usr/bin bin; do \
			candidate="$(TARGET_DIR)/$$dir/$$bin"; \
			if [ -x "$$candidate" ]; then \
				src="$$candidate"; \
				break; \
			fi; \
		done; \
		if [ -z "$$src" ]; then \
			echo "citronics-initramfs: $$bin not found in the target" >&2; \
			exit 1; \
		fi; \
		relpath=$$(realpath --relative-to=$(TARGET_DIR) $$src); \
		dest="$(CITRONICS_INITRAMFS_STAGING)/$$relpath"; \
		mkdir -p "$$(dirname $$dest)"; \
		cp -aL "$$src" "$$dest"; \
		$(CITRONICS_INITRAMFS_PKG_DIR)/scripts/copy_libs_for_binary.sh \
			$$src $(TARGET_DIR) $(CITRONICS_INITRAMFS_STAGING) $(TARGET_READELF) ; \
	done

	cd $(CITRONICS_INITRAMFS_STAGING)/bin && \
		ln -sf busybox sh && \
		ln -sf busybox telnetd && \
		ln -sf busybox getty

	(cd $(CITRONICS_INITRAMFS_STAGING) && \
		find . | LC_ALL=C sort | cpio -o -H newc --owner root:root --reproducible > ../initramfs.cpio)
	gzip -9 -f -n $(@D)/initramfs.cpio
	cp $(@D)/initramfs.cpio.gz $(BINARIES_DIR)/initramfs.gz
endef

$(eval $(generic-package))
