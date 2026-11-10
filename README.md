# lunar-settings

System settings of [Lunar](https://github.com/WhitePeace36/LunarOs) (KDE Plasma
on Arch Linux with the linux-lunar kernel), as one package.

`files/` mirrors the filesystem of the installed system:
`files/usr/lib/sysctl.d/70-lunar.conf` is installed as
`/usr/lib/sysctl.d/70-lunar.conf`.

## Where each setting lives

| Setting | File (under `files/`) |
|---|---|
| sysctl | `usr/lib/sysctl.d/70-lunar.conf` |
| tmpfiles (THP, khugepaged, zswap, MGLRU) | `usr/lib/tmpfiles.d/lunar-thp.conf` |
| Kernel command line | `usr/lib/lunar/cmdline.d/10-lunar.conf`, `etc/lunar/cmdline.conf` |
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
touches: `/etc/sysctl.d/99-local.conf`, or a file with the same name in
`/etc/tmpfiles.d/`.

## Kernel command line

`lunar-update-cmdline` writes `/etc/kernel/cmdline` and the systemd-boot
entries from, in this order:

1. `/etc/lunar/cmdline-root`: this machine's root options (written by the
   installer)
2. `/usr/lib/lunar/cmdline.d/*.conf`: Lunar's parameters
3. `/etc/lunar/cmdline.d/*.conf`: the user's parameters

Nothing is merged or removed. When a parameter appears twice, the kernel uses
the last one, so the user's parameters always win. With `LUNAR_DEFAULTS=no`
in `/etc/lunar/cmdline.conf`, step 2 is left out: only the root options and
the user's files are used.

A pacman hook runs it after every kernel install, update or removal and
after lunar-settings updates; `sudo lunar-update-cmdline` applies changes
right away. `lunar-update-cmdline --print` shows the result.

The settings are tuned for desktops: CPU idle limited to C1, no PCIe power
saving, performance governor, disks and sound chip never powered down. On a
laptop this costs battery life.

## Building

```sh
makepkg -si
```

All dependencies come from Arch's repos. The Lunar packages these settings
are made for (`ananicy-cpp-lunar`, `lunar-ananicy-rules`, `elara`) are
optional dependencies; the Lunar installer installs them.

On a system that wasn't installed with Lunar's installer (no
`/etc/lunar/cmdline-root`), the kernel parameters and systemd-boot tools do
nothing, so the boot setup of another distribution is never touched. The
other settings (sysctl, tmpfiles, udev, ...) do apply. Packages of the other
distribution may ship files at the same paths (for example
`/usr/lib/systemd/zram-generator.conf`); pacman then refuses to install.

## Releasing a change

1. Edit the file(s). A new file just goes into `files/` at its final path.
2. Raise `pkgver` in `PKGBUILD` (e.g. 2.0.2 -> 2.1.0), or `pkgrel` for a
   small fix. Commit and push.
3. In the `LunarOs` repo: set `_commit` in `packages/lunar-settings/prepare.sh`
   to the new commit, then `scripts/build-packages.sh lunar-settings` and
   `scripts/publish.sh`.

On the next `pacman -Syu`, Arch's systemd pacman hooks apply changed sysctl
and tmpfiles files right away. Kernel command line changes rewrite the boot
entries (`lunar-update-cmdline` hook) and need a reboot. udev and modprobe
changes take effect at the next boot.

## License

GPL-2.0-only, see `LICENSE`.
