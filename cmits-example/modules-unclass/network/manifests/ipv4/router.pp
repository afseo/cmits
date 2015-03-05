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
# \subsubsection{IPv4 routers}

class network::ipv4::router {

    case $::osfamily {
        'redhat': {
# \implements{unixsrg}{GEN005600}%
# Turn on IPv4 forwarding for Red Hat hosts designated as routers.
            augeas { "ipv4_forwarding":
                context => "/files/etc/sysctl.conf",
                changes => "set net.ipv4.ip_forward 1",
            }
        }
        'darwin': {
# \implements{macosxstig}{GEN005600 M6}%
# \implements{mlionstig}{OSX8-00-01205}%
# Turn on IPv4 forwarding for Macs designated as routers.
            augeas { "ipv4_forwarding":
                context => "/files/etc/sysctl.conf",
                changes => "set net.inet.ip.forwarding 1",
            }
        }
        default:  { unimplemented() }
    }
}
