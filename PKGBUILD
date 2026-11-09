# Maintainer: Timon <timon2201@gmail.com>
#
# All of Lunar's system settings. This PKGBUILD builds three packages from the
# folders next to it, as they are on disk (nothing is downloaded). Each folder
# mirrors the filesystem, e.g. common/usr/lib/sysctl.d/70-lunar.conf is
# installed as /usr/lib/sysctl.d/70-lunar.conf:
#
#   common/       -> lunar-settings            both profiles: sysctl, THP/tmpfiles,
#                                              zram, limits, mDNS, I/O schedulers,
#                                              boot entries, GPU setup, ...
#   performance/  -> lunar-tuning-performance  "Full performance" profile
#   battery/      -> lunar-tuning-battery      "Battery friendly" profile
#
# Build from this checkout and install lunar-settings plus ONE profile
# (makepkg -si would try to install both profiles, which conflict):
#   makepkg -s
#   sudo pacman -U lunar-settings-[0-9]*.pkg.tar.zst lunar-tuning-performance-*.pkg.tar.zst
#
# Releasing a change for Lunar: edit the files, raise pkgver (or pkgrel),
# commit and push, then in the lunar repo set _commit in
# packages/lunar-settings/prepare.sh and run
#   scripts/build-packages.sh lunar-settings && scripts/publish.sh

pkgbase=lunar-settings
pkgname=('lunar-settings' 'lunar-tuning-performance' 'lunar-tuning-battery')
pkgver=1.1.0
pkgrel=1
arch=('any')
url='https://github.com/WhitePeace36/lunar-settings'
license=('GPL-3.0-or-later')

# copy one folder into the package, keep the modes of the files in git
_install_tree() {
  cp -a --no-preserve=ownership "$startdir/$1/." "$pkgdir/"
}

package_lunar-settings() {
  pkgdesc='Lunar - system settings (sysctl, THP, zram, limits, mDNS, boot entries, GPU setup)'
  # depends are listed here and not globally: lunar-tuning is built by this
  # same PKGBUILD and must not be needed at build time
  depends=(
    'ananicy-cpp-lunar'
    'lunar-ananicy-rules'
    'elara'
    'zram-generator'
    'avahi'
    'nss-mdns'
    'wireless-regdb'
    'pciutils'
    'most'
    'micro'
    'systemd>=256'
    'lunar-tuning'
  )
  optdepends=('networkmanager: DNS through systemd-resolved'
              'ufw: the LocalSend firewall rule')
  backup=('etc/security/limits.d/90-lunar.conf')
  install=lunar-settings.install

  _install_tree common
  chmod 755 "$pkgdir/usr/bin/"* "$pkgdir/etc/profile.d/"*.sh
}

package_lunar-tuning-performance() {
  pkgdesc='Lunar - full performance tuning profile'
  depends=('systemd' 'hdparm')
  optdepends=('power-profiles-daemon: start in the "performance" power profile')
  provides=('lunar-tuning')
  conflicts=('lunar-tuning')
  install=lunar-tuning-performance.install

  _install_tree performance
  chmod 755 "$pkgdir/usr/lib/lunar/amdgpu-performance" \
            "$pkgdir/usr/lib/systemd/system-sleep/lunar-amdgpu-performance"
}

package_lunar-tuning-battery() {
  pkgdesc='Lunar - battery-friendly tuning profile'
  depends=('systemd')
  optdepends=('power-profiles-daemon: switch power profiles from the panel')
  provides=('lunar-tuning')
  conflicts=('lunar-tuning')

  _install_tree battery
}
