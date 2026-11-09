# lunar-settings

System settings of [Lunar](https://github.com/WhitePeace36/lunar) (KDE Plasma
on Arch Linux with the linux-lunar kernel): sysctl, transparent hugepages and
other tmpfiles, zram, limits, kernel command line, udev rules, mDNS, the
systemd-boot entry and GPU driver tools, and the two tuning profiles.

One PKGBUILD, three packages. Every folder mirrors the filesystem of the
installed system: `common/usr/lib/sysctl.d/70-lunar.conf` is installed as
`/usr/lib/sysctl.d/70-lunar.conf`.

| Folder | Package | Installed |
|---|---|---|
| `common/` | `lunar-settings` | always |
| `performance/` | `lunar-tuning-performance` | "Full performance" profile |
| `battery/` | `lunar-tuning-battery` | "Battery friendly" profile |

The two profile packages conflict (`provides=lunar-tuning`); the installer
picks one, and you switch with `sudo pacman -S lunar-tuning-battery`
(or `-performance`).

## Where each setting lives

| Setting | Both profiles (`common/`) | Per profile (`performance/`, `battery/`) |
|---|---|---|
| sysctl | `usr/lib/sysctl.d/70-lunar.conf` | `usr/lib/sysctl.d/75-lunar-tuning.conf` |
| tmpfiles (THP, zswap, MGLRU, khugepaged) | `usr/lib/tmpfiles.d/lunar-thp.conf` | `usr/lib/tmpfiles.d/lunar-tuning.conf` |
| Kernel command line | `usr/lib/lunar/cmdline.d/10-common.conf` | `usr/lib/lunar/cmdline.d/50-tuning.conf` |
| Environment variables | `usr/lib/environment.d/60-lunar.conf`, `etc/profile.d/lunar-env.sh` | - |
| Limits | `etc/security/limits.d/90-lunar.conf`, `usr/lib/systemd/{system,user}.conf.d/` | - |
| zram | `usr/lib/systemd/zram-generator.conf` | - |
| udev (I/O scheduler, disks, AMD GPU) | `usr/lib/udev/rules.d/60-lunar-ioscheduler.rules` | `usr/lib/udev/rules.d/60-lunar-disk-performance.rules`, `90-lunar-amdgpu-performance.rules` |
| Kernel modules | `usr/lib/modprobe.d/`, `usr/lib/modules-load.d/` | `usr/lib/modprobe.d/lunar-audio-performance.conf` |
| Services | enabled in `lunar-settings.install` | `lunar-tuning-performance.install` |

Files are read in name order and a later file wins, so the profile values
(`75-…`) override the common ones (`70-…`). Users override both with their own
file in `/etc` (`/etc/sysctl.d/99-local.conf`, `/etc/tmpfiles.d/…` with the
same name, `/etc/lunar/cmdline.d/…`), which pacman never touches.

## Building

```sh
makepkg -s
sudo pacman -U lunar-settings-[0-9]*.pkg.tar.zst lunar-tuning-performance-*.pkg.tar.zst
```

Install `lunar-settings` and one of the two profile packages (`makepkg -si`
would try to install both profiles, which conflict). Outside Lunar,
`lunar-settings` needs the other Lunar packages it depends on
(`ananicy-cpp-lunar`, `lunar-ananicy-rules`, `elara`) from the `[lunar]` repo.

## The profiles and linux-lunar

linux-lunar compiles in memory defaults that trade background work for fewer
stalls (`vm.defrag_mode=1`, `vm.watermark_scale_factor=500`,
`vm.compaction_proactiveness=50`, khugepaged scanning 8x as fast, writeback
every second). The performance profile keeps them. The battery profile sets
them back towards upstream (`75-lunar-tuning.conf`, `lunar-tuning.conf`), so
kswapd, kcompactd and khugepaged wake up less. linux-lunar's patches
themselves don't add background work: they only change who does the work
(kswapd/kcompactd instead of the program that allocates).

## Releasing a change

1. Edit the file(s). A new file just goes into the right folder at its
   final path.
2. Raise `pkgver` in `PKGBUILD` (e.g. 1.1.0 -> 1.2.0), or `pkgrel` for a
   small fix. All three packages get the new version. Commit and push.
3. In the `lunar` repo: set `_commit` in `packages/lunar-settings/prepare.sh`
   to the new commit, then `scripts/build-packages.sh lunar-settings` and
   `scripts/publish.sh`.

On the next `pacman -Syu`, Arch's systemd pacman hooks apply changed sysctl
and tmpfiles files right away. Kernel command line changes rewrite the boot
entries (`lunar-update-cmdline` hook) and need a reboot. udev and modprobe
changes take effect at the next boot.

## License

GPL-2.0-only, see `LICENSE`.
