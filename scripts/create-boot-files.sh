#!/bin/sh
#
# create-boot-files.sh
#
# Stages, in $BINARIES_DIR, what fwup.conf puts into a FAT boot slot and the
# images for the tablet's `boot` partition:
#
#   zImage, mt8127-lenovo-tb3-710f.dtb   from the kernel build
#   zImage-dtb                           zImage with the DTB appended
#   initramfs.gz                         from the citronics-initramfs package
#   extlinux/extlinux.conf               from this system
#   boot.img                             for the `boot` partition: Android
#                                        boot.img (LK format) whose "kernel"
#                                        is u-boot.bin, with an empty ramdisk
#   linux-boot.img                       debug only: the same format with
#                                        zImage-dtb + the initramfs, booted by
#                                        LK without U-Boot (no kernel A/B)
#
# Inputs (env, from Buildroot's post-image stage):
#   $BINARIES_DIR, $NERVES_DEFCONFIG_DIR

set -e

DTB=mt8127-lenovo-tb3-710f.dtb
# The `boot` partition is 16 MiB.
BOOT_PARTITION_BYTES=16777216
# BOOT_A_PART_COUNT in fwup_include/fwup-common.conf, in bytes, minus room
# for the FAT itself.
BOOT_SLOT_LIMIT=$((131072 * 512 - 4 * 1024 * 1024))

fail() { echo "create-boot-files.sh: $*" >&2; exit 1; }

cd "$BINARIES_DIR"
for f in zImage "$DTB" initramfs.gz u-boot.bin; do
    [ -f "$f" ] || fail "no $f in $BINARIES_DIR"
done

cat zImage "$DTB" > zImage-dtb

mkdir -p extlinux
cp "$NERVES_DEFCONFIG_DIR/extlinux/extlinux.conf" extlinux/extlinux.conf

slot_bytes=$(cat zImage "$DTB" zImage-dtb initramfs.gz extlinux/extlinux.conf | wc -c)
[ "$slot_bytes" -le "$BOOT_SLOT_LIMIT" ] || \
    fail "boot slot payload is $slot_bytes bytes, more than $BOOT_SLOT_LIMIT"

# The same APPEND line as extlinux.conf. LK passes it in the ATAGs and the
# kernel appends it to the bootargs of the appended DTB
# (ARM_ATAG_DTB_COMPAT_CMDLINE_EXTEND).
cmdline=$(sed -n 's/^[[:space:]]*append[[:space:]]*//p' extlinux/extlinux.conf)
"$NERVES_DEFCONFIG_DIR/scripts/mkbootimg.py" zImage-dtb initramfs.gz linux-boot.img \
    --cmdline "$cmdline"
[ "$(wc -c < linux-boot.img)" -le "$BOOT_PARTITION_BYTES" ] || \
    fail "linux-boot.img is larger than the 16 MiB boot partition"

# The arguments of buildroot-android's board/tb3_710f/scripts/create_boot_image.sh:
# u-boot.bin in the kernel slot, an archive with no entries as the ramdisk
# (LK wants one).
printf '' | cpio -o -H newc 2>/dev/null | gzip -9 -n > empty.cpio.gz
"$NERVES_DEFCONFIG_DIR/scripts/mkbootimg.py" u-boot.bin empty.cpio.gz boot.img
[ "$(wc -c < boot.img)" -le "$BOOT_PARTITION_BYTES" ] || \
    fail "boot.img is larger than the 16 MiB boot partition"
