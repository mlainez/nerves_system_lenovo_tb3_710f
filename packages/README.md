# Buildroot packages

Every package's `Config.in` title carries a scope tag indicating how
hardware-specific it is.

| Tag | Meaning |
|---|---|
| `[TB3-710F]` | Bound to this tablet. |
| `[Generic]` | No hardware dependency. |

The `mt8127-*`, `tb3-tools` and `tb3-audio` packages build sources of
[Spin42/buildroot-android](https://github.com/Spin42/buildroot-android) at
the commit in `external.mk` (`TB3_BRA_VERSION`): one tarball, of which each
package extracts its own directory. Their `.mk` glue follows the Buildroot
board's packages, without the init scripts.

| Package | Notes |
|---|---|
| `citronics-initramfs` | Early-boot initramfs in each boot slot: maps the nested partitions of `mmcblk0p7` with kpartx, mounts the rootfs, switch_root; USB telnet recovery on failure. Patches follow `nerves_system_fp3` and `nerves_system_s3ve3g`. |
| `unudhcpd` | Single-address DHCP server for the initramfs recovery network. |
| `mt8127-btif`, `-consys`, `-wmt`, `-wlan`, `-bt`, `-fm` | Out-of-tree CONSYS stack: BTIF, CONSYS power/clock, WMT core, Wi-Fi (`wlan_mt`), Bluetooth (`mtk_consys_bt`), FM (`mtk_consys_fm`, `fm-radio`). |
| `mt8127-camera` | `mtk_camsys` and the SP2508/SP0A20 sensor drivers. |
| `tb3-firmware` | Proprietary firmware from a local directory (`firmware/`). |
| `tb3-tools` | `tb3-pmic` and `reboot-mode` (MT6323 RTC bits read by LK). |
| `tb3-audio` | ALSA mixer state for the TB3-710F card. |
