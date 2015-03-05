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
# \section{ip6tables}
#
# \verb!ip6tables! is the IPv6 packet filter under Linux.
#
# \implements{unixsrg}{GEN008520} Employ a local firewall for IPv6, using
# \verb!ip6tables!.
#
# \verb!ip6tables! rules are constructed in this policy from
# templates. This lets us group related rules, and include them as a
# whole; it makes explicit the order of the rules, which is quite
# important; and it lets us have both sets of rules general to a whole
# class of host (\emph{e.g.} workstations) and sets of rules specific
# to a single host (\emph{e.g.} \verb!sumo!).
#
class ip6tables {
    package { 'iptables-ipv6': 
        ensure => present,
    }
    service { 'ip6tables':
        ensure => running,
        hasstatus => true,
    }
}

# The actual firewall rules that implement the following requirements are in
# the templates for this module, not here; but here is the place where they can
# be indexed, summarized and prose written about them, so here they are
# documented.
#
# \implements{unixsrg}{GEN003605,GEN003606} Configure the local firewall to
# reject all source-routed IPv6 packets, even those generated locally.
#
# Source routing in IPv6 is done with Routing Header 0 (RH0); we merely need to
# drop every packet that has that optional header.
#
# \implements{unixsrg}{GEN008540} Configure the local firewall to reject all
# IPv6 packets by default, allowing only by exception.
#
# \implements{unixsrg}{GEN003602,GEN003604} Configure the local firewall to
# reject ICMPv6 timestamp requests, including those sent to a broadcast address.
