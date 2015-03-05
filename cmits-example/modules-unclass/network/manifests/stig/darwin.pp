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
# \subsection{STIG-required network configuration under Mac OS X}

class network::stig::darwin {
# First ensure that sysctl.conf exists; the STIG implies that it may not.
#
# \index{g}{FIXME}%
# For least surprise for policy maintainers, this should probably go in a more
# generic module than ``network.''
    file { '/etc/sysctl.conf':
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }
# All of our edits will be to sysctl.conf.
    Augeas {
        context => "/files/etc/sysctl.conf",
    }

    augeas {
# \implements{macosxstig}{GEN003602 M6}%
# \implements{mlionstig}{OSX8-00-01220}%
# Configure the system to block ICMP timestamp requests.
        "block_icmp_timestamp_requests":
            changes => "set net.inet.icmp.timestamp 1";
# \implements{macosxstig}{GEN003603 M6}%
# \implements{mlionstig}{OSX8-00-01190}%
# Configure the system to ignore ICMP pings sent to a broadcast address.
        "ignore_icmpv4_broadcast_echoreq":
            changes => "set net.inet.icmp.bmcastecho 1";
# \implements{macosxstig}{GEN003606 M6}%
# \implements{mlionstig}{OSX8-00-01215}%
# Configure the system to ``prevent local applications from generating
# source-routed packets.''
        "prevent_outgoing_source_routing":
            changes => "set net.inet.ip.sourceroute 0";
# \implements{macosxstig}{GEN003607 M6}%
# \implements{mlionstig}{OSX8-00-01195}%
# Configure the system to ``not accept source-routed IPv4 packets.''
        "reject_ipv4_source_routed":
            changes => "set net.inet.ip.accept_sourceroute 0";
# \implements{macosxstig}{GEN003609 M6}%
# \implements{mlionstig}{OSX8-00-01200}%
# Configure the system to ``ignore ICMPv4 redirect messages.''
#
# A typo in the earlier Mac OS X stig said to make this 0.
        "ignore_icmpv4_redirects":
            changes => "set net.inet.icmp.drop_redirect 1";
# \implements{macosxstig}{GEN003610 M6}%
# \implements{mlionstig}{OSX8-00-01210}%
# Prevent the system from sending ICMPv4 redirect messages.
        "dont_send_icmpv4_redirects":
            changes => "set net.inet.ip.redirect 0";
    }
    include network::ike::no
}
