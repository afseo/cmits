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
# \subsubsection{Under Red Hat}
# \implements{unixsrg}{GEN008500} Disable Firewire ``unless needed.'' We do not
# need it.

class ieee1394::no::redhat {
    kernel_module {
        "firewire-core": ensure => absent;
        "firewire-ohci": ensure => absent;
        "firewire-sbp2": ensure => absent;
        "firewire-net": ensure => absent;
    }
    file {
        "/lib/modules/$kernelrelease/kernel/drivers/firewire":
            ensure => absent, recurse => true,
            recurselimit => 1, force => true;
    }
}
# To reinstate IEEE 1394 support on a host which has previously had it
# disabled in the above manner, you must reinstall the kernel package and
# restart the host.
