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
# \paragraph{Turn off IPv6 under RHEL}

class network::ipv6::no::redhat {
    define ipv6init_no() {
        augeas { "${name}_turn_off_ipv6":
            changes => "set IPV6INIT no",
            context => 
        "/files/etc/sysconfig/network-scripts/ifcfg-${name}",
            onlyif => "match \
        /files/etc/sysconfig/network-scripts/ifcfg-${name} \
                size == 1",
        }
    }
    ipv6init_no { 
        "eth0":;
        "eth1":;
        "lo":;
    }

    include network::ipv6::no_6to4

# When postfix tries to listen on localhost, if it finds an IPv6 address in
# \verb!/etc/hosts! it will try to listen on it. If we've disabled IPv6, it
# will fail, and then it will quit. So we need to remove that IPv6 address for
# localhost.
    augeas { "hosts_remove_localhost6":
            context => "/files/etc/hosts",
            changes => "rm *[ipaddr='::1']",
    }

# \implements{unixsrg}{GEN007700,GEN007720}%
# Unbind the IPv6 protocol from all network interfaces at boot time.
#
# Testing has shown that this also prevents dynamic loading of IPv6 modules by
# means of attempting to use IPv6.
    $n6c = "net.ipv6.conf"
    augeas { "sysctl_disable_ipv6":
        context => "/files/etc/sysctl.conf",
        changes => [
            "set $n6c.all.disable_ipv6 1",
            "set $n6c.default.disable_ipv6 1",
        ],
    }

# \notapplicable{unixsrg}{GEN007740}%
# This requirement says that the IPv6 protocol handler ``must not be installed
# unless needed.'' But it could be needed in the future, and its removal is not
# easily reversible because it isn't in a separate package. So, because it will
# be ``needed'' in the future, we settle for disabling it here.
#
# Disabling IPv6 entirely as just above causes an obscure problem with X
# forwarding in \verb!ssh!. Not that I would know about that, because we
# disabled X forwarding.
    include ssh::no_ipv6
}
    
# \notapplicable{unixsrg}{GEN005570}%
# No hosts on the Eglin network use IPv6, so they are not configured for an
# IPv6 default gateway.
#
# \bydefault{RHEL6}{unixsrg}{GEN007800}%
# RHEL6 provides no packages or loadable kernel modules that support Teredo.
