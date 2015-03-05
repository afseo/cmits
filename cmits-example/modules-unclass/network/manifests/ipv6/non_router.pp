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
# \subsubsection{IPv6 non-routers}

class network::ipv6::non_router {

    case $::osfamily {
        'redhat': {
# \implements{unixsrg}{GEN005590} Remove IPv6 routing protocol daemons from
# non-routing systems.
            package {
                "quagga": ensure => absent;
                "radvd": ensure => absent;
            }
# \implements{unixsrg}{GEN005610} Turn off IPv6 forwarding for
# non-routers.
            augeas { "no_ipv6_forwarding":
                context => "/files/etc/sysctl.conf",
                changes => "set ipv6.conf.all.forwarding 0",
            }
        }
        'darwin': {
# The Mac OS X STIG appears to have no requirements for us to do anything here.
        }
        default:  { unimplemented() }
    }
}

