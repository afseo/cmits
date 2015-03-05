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
# \subsection{IPv6}
#
# On some networks we need IPv6 enabled. This class enables it. See below
# for a class which disables it.

class network::ipv6 {
    define ipv6init_yes() {
        augeas { "${name}_turn_on_ipv6":
            changes => "set IPV6INIT yes",
            context => 
        "/files/etc/sysconfig/network-scripts/ifcfg-${name}",
            onlyif => "match \
        /files/etc/sysconfig/network-scripts/ifcfg-${name} \
                size == 1",
        }
    }
    ipv6init_yes { 
        "eth0":;
        "eth1":;
        "lo":;
    }

# Even when IPv6 is enabled, we still must disable 6to4.
    include network::ipv6::no_6to4

# The localhost6 hosts entry may have been removed. Put it back.
    augeas { "hosts_ensure_localhost6":
        context => '/files/etc/hosts',
        onlyif => 'match *[ipaddr="::1"] size == 0',
        changes => [
            'set 999/ipaddr "::1"',
            'set 999/canonical "localhost6"',
            'set 999/alias     "localhost6.localdomain6"',
        ],
    }

# \implements{unixsrg}{GEN007700,GEN007720}%
# ``The IPv6 protocol handler must not be bound to the network stack unless
# needed,'' and ``must be prevented from dynamic loading unless needed.'' Hosts
# which include this class need IPv6.
    $n6c = "net.ipv6.conf"
    augeas { "sysctl_disable_ipv6":
        context => "/files/etc/sysctl.conf",
        changes => [
            "set $n6c.all.disable_ipv6 0",
            "set $n6c.default.disable_ipv6 0",
        ],
    }

# \notapplicable{unixsrg}{GEN007740}%
# By the same token, the ``IPv6 protocol handler'' is needed, so we do not
# uninstall it.
#
# Undo any SSH-specific IPv6 disabling which may have been done.
    include ssh::ipv6
}
    
# \notapplicable{unixsrg}{GEN005570}%
# Non-gateway, IPv6-supporting systems will be configured with a default IPv6
# gateway by means of DHCPv6. The DHCPv6 server and its configuration may run
# on Windows servers, and thus may be outside the scope of this document.
#
# \bydefault{RHEL6}{unixsrg}{GEN007800}%
# RHEL6 provides no packages or loadable kernel modules that support Teredo.
