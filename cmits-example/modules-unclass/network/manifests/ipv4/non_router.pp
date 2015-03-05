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
# \subsubsection{IPv4 non-routers}

class network::ipv4::non_router {

    case $::osfamily {
        'redhat': {
# \implements{unixsrg}{GEN005600}%
# Turn off IPv4 forwarding for non-router Red Hat hosts.
            augeas { "no_ipv4_forwarding":
                context => "/files/etc/sysctl.conf",
                changes => "set net.ipv4.ip_forward 0",
            }
        }
        'darwin': {
# \implements{macosxstig}{GEN005600 M6}%
# \implements{mlionstig}{OSX8-00-01205}%
# Turn off IPv4 forwarding for non-router Macs.
            augeas { "no_ipv4_forwarding":
                context => "/files/etc/sysctl.conf",
                changes => "set net.inet.ip.forwarding 0",
            }
        }
        default:  { unimplemented() }
    }
}
