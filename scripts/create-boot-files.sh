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
#   linux-boot.img                       debug only: Android boot.img (LK
#                                        format) with zImage-dtb + the
#                                        initramfs, see the README
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
for f in zImage "$DTB" initramfs.gz; do
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

# TODO(u-boot): once the MT8127/TB3 U-Boot series exists (buildroot-android,
# branch tb3-710f-uboot), pack $BINARIES_DIR/u-boot.bin into boot.img here
# with the same mkbootimg.py arguments as the Buildroot board
# (board/tb3_710f/scripts/create_boot_image.sh).
