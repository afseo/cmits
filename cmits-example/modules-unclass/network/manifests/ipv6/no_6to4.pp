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
# \subsubsection{Disable 6to4}
#
# \implements{unixsrg}{GEN007780} Disable 6to4.
#
# See \verb!/usr/share/doc/initscripts-9.03.17/ipv6-6to4.howto!.

class network::ipv6::no_6to4 {
    define ipv6to4init_no() {
        augeas { "${name}_turn_off_6to4":
            changes => "set IPV6TO4INIT no",
            context => 
        "/files/etc/sysconfig/network-scripts/ifcfg-${name}",
            onlyif => "match \
        /files/etc/sysconfig/network-scripts/ifcfg-${name} \
                size == 1",
        }
    }
    ipv6to4init_no {
        "eth0":;
        "eth1":;
        "lo":;
    }
    augeas {
        "network_turn_off_6to4":
            context => "/files/etc/sysconfig/network",
            changes => "rm IPV6_DEFAULTDEV",
            onlyif => "get IPV6_DEFAULTDEV == 'tun6to4'";
    }
}
