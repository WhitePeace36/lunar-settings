# Maintainer: Timon <timon2201@gmail.com>
#
# All of Lunar's system settings: sysctl, transparent hugepages and other
# tmpfiles, zram, limits, kernel command line, udev rules (I/O schedulers,
# disks, AMD GPU), mDNS, environment, the systemd-boot entry tools and
# lunar-gpu-setup.
#
# files/ mirrors the filesystem: files/usr/lib/sysctl.d/70-lunar.conf is
# installed as /usr/lib/sysctl.d/70-lunar.conf. Nothing is downloaded.
#
# Build and install from this checkout:   makepkg -si
#
# Releasing a change for Lunar: edit the files, raise pkgver (or pkgrel),
# commit and push, then in the lunar repo set _commit in
# packages/lunar-settings/prepare.sh and run
#   scripts/build-packages.sh lunar-settings && scripts/publish.sh

pkgname=lunar-settings
pkgver=2.0.0
pkgrel=1
pkgdesc='Lunar - system settings (sysctl, THP, zram, limits, kernel parameters, mDNS, boot entries, GPU setup)'
arch=('any')
url='https://github.com/WhitePeace36/lunar-settings'
license=('GPL-2.0-only')
depends=(
  'ananicy-cpp-lunar'
  'lunar-ananicy-rules'
  'elara'
  'zram-generator'
  'avahi'
  'nss-mdns'
  'wireless-regdb'
  'pciutils'
  'hdparm'
  'most'
  'micro'
  'systemd>=256'
)
optdepends=('networkmanager: DNS through systemd-resolved'
            'ufw: the LocalSend firewall rule'
            'power-profiles-daemon: start in the "performance" power profile')
# the two tuning profiles of 1.x are part of this package now
provides=('lunar-tuning')
conflicts=('lunar-tuning' 'lunar-tuning-performance' 'lunar-tuning-battery')
replaces=('lunar-tuning-performance' 'lunar-tuning-battery')
backup=('etc/security/limits.d/90-lunar.conf')
install=lunar-settings.install

package() {
  cp -a --no-preserve=ownership "$startdir/files/." "$pkgdir/"
  chmod 755 "$pkgdir/usr/bin/"* "$pkgdir/etc/profile.d/"*.sh \
            "$pkgdir/usr/lib/lunar/amdgpu-performance" \
            "$pkgdir/usr/lib/systemd/system-sleep/lunar-amdgpu-performance"
}
