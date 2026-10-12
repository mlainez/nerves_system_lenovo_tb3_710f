# Nerves System: Lenovo Tab3 7 (TB3-710F)

Nerves system for the **Lenovo Tab3 7 Essential (TB3-710F)**: MediaTek MT8127, armv7.

| Feature | Description |
| --- | --- |
| CPU | 4x Cortex-A7 @ 1.3 GHz (MT8127), armv7 |
| Memory | 1 GB |
| Storage | 8 GB eMMC; firmware lives inside the stock `userdata` partition (`mmcblk0p7`) |
| Display | 1024x600 LVDS/DSI panel (`mediatek-drm`, HX8282), Mali-450 (`lima`) |
| Linux | `mlainez/linux-mt8127` `6.18/staging` (v6.18.55 + MT8127/TB3 work), pinned commit in `nerves_defconfig` |
| Bootloader | MTK preloader -> LK -> mainline U-Boot v2026.10 on `boot` (`images/boot.img`, `patches/uboot`) -> `extlinux/extlinux.conf` on the active boot slot |
| Console | On-device display (`tty1`); ssh over USB (`usb0`, g_ether) |
| Wi-Fi / BT / FM | MT8127 CONSYS through the out-of-tree WMT stack (`mt8127-*` packages) |
| Audio | MT6323 codec through the MT8127 AFE; mixer state in `/var/lib/alsa/asound.state` |
| Cameras | SP2508 / SP0A20 through `mtk_camsys` (kernel side only, no libcamera yet) |

## Status

Builds; the layout and every fwup task are checked on files on the host
(`scripts/host-check-fwup.sh`). **Not yet booted on the tablet.** U-Boot
boots extlinux on the tablet (Buildroot root on `mmcblk0p7`); the U-Boot
patch that reads the boot slots nested in `mmcblk0p7` is being written.

## Layout

The tablet's partition table is never changed. The whole firmware is nested
in the stock `userdata` partition, as in `nerves_system_fp3`
(`fwup_include/fwup-common.conf`, offsets in 512-byte blocks relative to
`mmcblk0p7`):

| Region | Offset | Blocks | Size |
| --- | --- | --- | --- |
| nested MBR | 0 | 1 | |
| fwup env (U-Boot format) | 2048 | 16 | 8 KiB |
| Boot A (FAT) | 2064 | 131072 | 64 MiB |
| Boot B (FAT) | 133136 | 131072 | 64 MiB |
| Rootfs A (squashfs) | 264208 | 1048576 | 512 MiB |
| Rootfs B (squashfs) | 1312784 | 1048576 | 512 MiB |
| Application (f2fs, `/root`) | 2361360 | 8257520 | 4032 MiB |

The layout ends at block 10618880, before the end of USRDATA in the MTK
scatter (10623488): Linux shows `mmcblk0p7` 21 MiB larger than that, over
the vendor's bad-block (BMT) pool, which is never written. For the same
reason the application partition has a fixed size.

fwup rewrites the nested MBR on each upgrade and revert so that partition 1
is always the boot slot to run and partition 2 its rootfs. A boot slot holds
`/extlinux/extlinux.conf`, `/zImage`, `/mt8127-lenovo-tb3-710f.dtb`,
`/zImage-dtb` (the same zImage with the DTB appended) and `/initramfs.gz`.
The initramfs (`packages/citronics-initramfs`) maps the nested partitions
with kpartx (`/dev/mmcblk0p7p1..3`), mounts partition 2 and switch_roots into
erlinit; if that fails it brings up USB networking (10.0.42.1, the computer
gets 10.0.42.2) and a telnet shell.

Kernel, DTB, initramfs, modules and rootfs therefore change together and
revert together.

## Building

```bash
cp local.mk.example local.mk            # the kernel fork is not published yet
ln -s <prepared firmware dir> firmware  # see below
mix deps.get
mix compile
```

`firmware/` must hold the tablet's proprietary firmware laid out like
`/lib/firmware`, prepared with buildroot-android's
`board/tb3_710f/scripts/prepare_firmware.sh` from the stock kernel source and
the stock `/system/etc/firmware`. It is git-ignored and never redistributed.

The board packages (`packages/mt8127-*`, `tb3-tools`, `tb3-audio`) build the
sources of [Spin42/buildroot-android](https://github.com/Spin42/buildroot-android)
at the commit pinned in `external.mk`; `local.mk.example` shows how to build
them from a checkout instead.

## Using

```elixir
@all_targets [:lenovo_tb3_710f]

defp deps do
  [
    {:nerves_system_lenovo_tb3_710f,
     path: "../nerves_system_lenovo_tb3_710f", runtime: false,
     targets: :lenovo_tb3_710f, nerves: [compile: true]}
  ]
end
```

An upgraded slot stays unvalidated until the application calls
`Nerves.Runtime.validate_firmware/0`; nothing reverts automatically yet.

Hardware that needs an explicit step from the application (the Buildroot
port did these in init scripts):

| Buildroot init script | Here |
| --- | --- |
| `S05modules`, `S10mdev` | `nerves_runtime`'s uevent handling loads modules by modalias |
| `S30alsa` | `alsactl --no-ucm -f /var/lib/alsa/asound.state restore` once `/dev/snd/controlC0` exists |
| `S35bluetooth` | `modprobe mtk_consys_bt bdaddr=<address derived from the eMMC CID>` before bluetoothd |
| `S36fmradio` | `modprobe mtk_consys_fm` when the radio is wanted |
| `S40wifi` | `wlan_mt` loads by modalias; VintageNetWiFi on `wlan0`. `/etc/modprobe.d/tb3-wmt.conf` makes `modprobe -r` refuse to unload the WMT stack |
| `S45udhcpd`, `S40network` | VintageNet on `usb0` (10.0.42.1, DHCP server for 10.0.42.2) |
| `S50sshd` | `nerves_ssh` |

`hello_lenovo_tb3_710f` (`lib/hello_lenovo_tb3_710f/tb3/`) shows these steps
in Elixir.

The kernel reads firmware straight from `/lib/firmware` in the rootfs (no
user helper). The boot chain leaves the MTK watchdog armed (31 s maximum);
the kernel pings it until `nerves_heart` opens `/dev/watchdog0`, after which
a BEAM that stops beating for `HEART_BEAT_TIMEOUT` (30 s in the default
`vm.args`) resets the tablet. Keep that timeout under 31 s.

`reboot-mode bootloader` (from `tb3-tools`) reboots straight into LK's
fastboot.

## Installing

The image is written raw to `mmcblk0p7`; the `boot` partition gets
`images/boot.img` (U-Boot packed as LK's "kernel"). `images/linux-boot.img`
is a debug Android boot.img (zImage-dtb + initramfs, command line in the
header) that LK boots without U-Boot; its kernel is not A/B. The flash plan and the way back
(TWRP on `recovery`, the Buildroot `boot.img`) are in the port's
`dossier/nerves-layout-adr.md`.

## Host checks

```bash
scripts/host-check-fwup.sh                # stand-in images
BINARIES_DIR=.nerves/artifacts/<name>/images scripts/host-check-fwup.sh
```

builds `.fw` files, runs `complete` into a file the size of `mmcblk0p7`, and
checks the nested MBR, the environment, the FAT boot slot and the tasks
`upgrade`, `status`, `validate`, `revert`, `prevent-revert` and
`factory-reset`.
