#!/bin/sh

set -e

# Stage the boot slot files (kernel, DTB, initramfs, extlinux.conf).
$NERVES_DEFCONFIG_DIR/scripts/create-boot-files.sh

FWUP_CONFIG=$NERVES_DEFCONFIG_DIR/fwup.conf

# Hand off to nerves-common to bundle the .fw / .img archives.
$BR2_EXTERNAL_NERVES_PATH/board/nerves-common/post-createfs.sh $TARGET_DIR $FWUP_CONFIG
