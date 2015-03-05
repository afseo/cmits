# % --- BEGIN DISCLAIMER ---
# % Those who use this do so at their own risk;
# % AFSEO does not provide maintenance nor support.
# % --- END DISCLAIMER ---
# % --- BEGIN AFSEO_DATA_RIGHTS ---
# % This is a work of the U.S. Government and is placed
# % into the public domain in accordance with 17 USC Sec.
# % 105. Those who redistribute or derive from this work
# % are requested to include a reference to the original,
# % at <https://github.com/afseo/cmits>, for example by
# % including this notice in its entirety in derived works.
# % --- END AFSEO_DATA_RIGHTS ---
# \paragraph{Disable Bluetooth under Red Hat}
#
# \implements{unixsrg}{GEN007660}%
# Disable and/or uninstall Bluetooth protocols. (Notably, this requirement
# does not say, ``unless needed.'')

class network::bluetooth::no::redhat {
    package {
        "gnome-bluetooth.x86_64":               ensure => absent;
        "gnome-bluetooth-debuginfo.i686":       ensure => absent;
        "gnome-bluetooth-debuginfo.x86_64":     ensure => absent;
        "gnome-bluetooth-libs-devel.i686":      ensure => absent;
        "gnome-bluetooth-libs-devel.x86_64":    ensure => absent;
        "pulseaudio-module-bluetooth.x86_64":   ensure => absent;
        "bluez.x86_64":                         ensure => absent;
        "bluez-alsa.i686":                      ensure => absent;
        "bluez-alsa.x86_64":                    ensure => absent;
        "bluez-compat.x86_64":                  ensure => absent;
        "bluez-libs-devel.i686":                ensure => absent;
        "bluez-libs-devel.x86_64":              ensure => absent;
        "bluez-cups.x86_64":                    ensure => absent;
        "bluez-gstreamer.i686":                 ensure => absent;
        "bluez-gstreamer.x86_64":               ensure => absent;
        "bluez-utils.i686":                     ensure => absent;
        "bluez-utils.x86_64":                   ensure => absent;
        "gvfs-obexftp.x86_64":                  ensure => absent;
        "obex-data-server.x86_64":              ensure => absent;
        "obexd.x86_64":                         ensure => absent;
    }
    kernel_module {
        "bnep":      ensure => absent;
        "rfcomm":    ensure => absent;
        "hidp":      ensure => absent;
        "bluetooth": ensure => absent;
        "cmtp":      ensure => absent;
        "sco":       ensure => absent;
        "l2cap":     ensure => absent;
    }
# ``Unprivileged local processes may be able to cause the system to dynamically
# load a protocol handler by opening a socket using the protocol.'' (SRG
# discussion) Prevent this by removing related kernel module files.
    file {
        "/lib/modules/$kernelrelease/kernel/net/bluetooth":
            ensure => absent,
            recurse => true,
            recurselimit => 2,
            force => true,
    }
}
