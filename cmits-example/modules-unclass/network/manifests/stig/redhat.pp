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
# \subsection{STIG-required network configuration under Red Hat}

class network::stig::redhat {
# All of our edits will be to sysctl.conf.
    Augeas { 
        context => "/files/etc/sysctl.conf",
    }
# Abbreviations used below:
    $n4 = "net.ipv4"
    $n4ca = "net.ipv4.conf.all"
    $n6ca = "net.ipv6.conf.all"
    augeas {
# \implements{unixsrg}{GEN003601}%
# Set the TCP backlog queue size appropriately.
        "increase_tcp_syn_backlog":
            changes => "set $n4.tcp_max_syn_backlog 1280";
# \implements{unixsrg}{GEN003603}%
# Configure the system to ignore ICMP pings sent to a broadcast address.
        "ignore_icmpv4_broadcast_echoreq":
            changes => "set $n4.icmp_echo_ignore_broadcasts 1";
# \implements{unixsrg}{GEN003607}%
# Configure the system to ignore source-routed IPv4 packets.
#
# Note that this setting is not enough to satisfy all of the STIG requirements
# regarding IPv4 source-routed packets. See~\S\ref{class_iptables}.
        "reject_ipv4_source_routed":
            changes => "set $n4ca.accept_source_route 0";
# \implements{unixsrg}{GEN003608}%
# Disable Proxy ARP.
        "disable_proxy_arp":
            changes => "set $n4ca.proxy_arp 0";
# \implements{unixsrg}{GEN003609}%
# Cause the system to ignore ICMPv4 redirect messages.
        "ignore_icmpv4_redirects":
            changes => "set $n4ca.accept_redirects 0";
# \implements{unixsrg}{GEN003610}%
# Prevent the system from sending ICMPv4 redirect messages.
        "dont_send_icmpv4_redirects":
            changes => "set $n4ca.send_redirects 0";
# \implements{unixsrg}{GEN003611}%
# Cause ``martian packets'' to be logged.
        "log_martian_packets":
            changes => "set $n4ca.log_martians 1";
# \implements{unixsrg}{GEN003612}%
# Enable TCP syncookies.
        "tcp_syncookies":
            changes => "set $n4.tcp_syncookies 1";
# \implements{unixsrg}{GEN003613}%
# Enable the reverse-path filter.
#
# Note: according to \url{https://access.redhat.com/knowledge/solutions/53031},
# the meaning of ``1'' differs between RHEL5 and RHEL6; in RHEL5 it means ``do
# source validation by reversed path'' (versus not doing it) and in RHEL6 it
# means ``Strict mode as defined in RFC3704 Strict Reverse Path'' (rather than
# no validation or ``loose mode''). In both cases this is the setting we want.
        "reverse_path_filter":
            changes => "set $n4ca.rp_filter 1";
# \implements{unixsrg}{GEN007860}%
# Cause the system to ignore ICMPv6 redirect messages.
        "ignore_icmpv6_redirects":
            changes => "set $n6ca.accept_redirects 0";
# \implements{unixsrg}{GEN007940}%
# Configure the system to ignore source-routed IPv6 packets.
        "reject_ipv6_source_routed":
            changes => "set $n6ca.accept_source_route 0";
    }

# \notapplicable{unixsrg}{GEN007880,GEN007920,GEN007950}%
# Some IPv6 requirements would be implemented with \verb!ip6tables!, as their
# corresponding IPv4 requirements are with \verb!iptables!.
#
# \notapplicable{unixsrg}{GEN007900}%
# Someone made an IPv6 \verb!rp_filter! patch for the Linux kernel in 2006. It
# appears that that patch is not in the RHEL kernel.  More investigation is
# needed, but not warranted at this time because we are not deploying IPv6 yet.

# \implements{rhel5stig}{GEN000000-LNX00480,GEN000000-LNX00500,GEN000000-LNX00520}%
    file { "/etc/sysctl.conf":
        owner => root, group => 0, mode => 0600,
    }
# \implements{rhel5stig}{GEN000000-LNX00530}%
    no_ext_acl { "/etc/sysctl.conf": }

    include network::no_dccp
    include network::no_rds
    include network::no_sctp
# Any system which is not a router should include the
# \verb!network::non_router! class for STIG compliance; but this class is
# generic enough that it may be included on designated routers.
    # include network::non_router
# Any host not using IPv6 should include network::ipv6::no.
}
