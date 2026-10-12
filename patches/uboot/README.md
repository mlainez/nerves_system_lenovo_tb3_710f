# U-Boot patches

MT8127 and Lenovo TB3-710F support for mainline U-Boot v2026.10: eMMC, MUSB
fastboot and USB mass storage, the board, its boot menu, and the Nerves boot
path (`blkmap` over the userdata image, `sysboot` of
`/extlinux/extlinux.conf` on nested partition 1).

Copied from Spin42/buildroot-android, branch `tb3-710f-uboot`,
`buildroot-external/board/tb3_710f/patches/uboot/`, at commit
a9c9121e (`tb3_710f: let U-Boot boot a raw gzip initramfs`). They build the same `u-boot.bin` as the boot image on the
tablet (`boot-uboot.img`, sha256 673039d8...). Update them there and copy them
again; the port's `dossier/uboot-feasibility.md` describes the series.
