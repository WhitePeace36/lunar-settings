# lunar-settings

System settings of [Lunar](https://github.com/WhitePeace36/lunar) (KDE Plasma
on Arch Linux with the linux-lunar kernel), as one package.

`files/` mirrors the filesystem of the installed system:
`files/usr/lib/sysctl.d/70-lunar.conf` is installed as
`/usr/lib/sysctl.d/70-lunar.conf`.

## Where each setting lives

| Setting | File (under `files/`) |
|---|---|
| sysctl | `usr/lib/sysctl.d/70-lunar.conf` |
| tmpfiles (THP, khugepaged, zswap, MGLRU) | `usr/lib/tmpfiles.d/lunar-thp.conf` |
| Kernel command line | `usr/lib/lunar/cmdline.d/10-lunar.conf` |
| Environment variables | `usr/lib/environment.d/60-lunar.conf`, `etc/profile.d/lunar-env.sh` |
| Limits | `etc/security/limits.d/90-lunar.conf`, `usr/lib/systemd/{system,user}.conf.d/` |
| zram | `usr/lib/systemd/zram-generator.conf` |
| udev: I/O scheduler, SATA/HDD power, AMD GPU | `usr/lib/udev/rules.d/60-lunar-ioscheduler.rules`, `60-lunar-disk-performance.rules`, `90-lunar-amdgpu-performance.rules` |
| AMD GPU max power limit + fixed VRAM clock | `usr/lib/lunar/amdgpu-performance`, `lunar-amdgpu-performance.service` |
| Kernel modules | `usr/lib/modprobe.d/`, `usr/lib/modules-load.d/` |
| Boot entries, kernel command line tools | `usr/bin/lunar-sdboot-update`, `usr/bin/lunar-update-cmdline`, `usr/share/libalpm/hooks/` |
| GPU driver selection | `usr/bin/lunar-gpu-setup` |
| Services enabled on install | `lunar-settings.install` |

Users override any of these with their own file in `/etc`, which pacman never
touches: `/etc/sysctl.d/99-local.conf`, a file with the same name in
`/etc/tmpfiles.d/`, or a copy of `10-lunar.conf` in `/etc/lunar/cmdline.d/`
(then `sudo lunar-update-cmdline`).

The settings are tuned for desktops: CPU idle limited to C1, no PCIe power
saving, performance governor, disks and sound chip never powered down. On a
laptop this costs battery life.

## Building

```sh
makepkg -si
```

Outside Lunar, `lunar-settings` needs the other Lunar packages it depends on
(`ananicy-cpp-lunar`, `lunar-ananicy-rules`, `elara`) from the `[lunar]` repo.

## Releasing a change

1. Edit the file(s). A new file just goes into `files/` at its final path.
2. Raise `pkgver` in `PKGBUILD` (e.g. 2.0.0 -> 2.1.0), or `pkgrel` for a
   small fix. Commit and push.
3. In the `lunar` repo: set `_commit` in `packages/lunar-settings/prepare.sh`
   to the new commit, then `scripts/build-packages.sh lunar-settings` and
   `scripts/publish.sh`.

On the next `pacman -Syu`, Arch's systemd pacman hooks apply changed sysctl
and tmpfiles files right away. Kernel command line changes rewrite the boot
entries (`lunar-update-cmdline` hook) and need a reboot. udev and modprobe
changes take effect at the next boot.

## License

GPL-2.0-only, see `LICENSE`.
