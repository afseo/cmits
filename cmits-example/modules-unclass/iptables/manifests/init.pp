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
# \section{iptables}
#
# \implements{unixsrg}{GEN008520} Employ a local firewall, using
# \verb!iptables!.
#
# \verb!iptables! rules are constructed in this policy from
# templates. This lets us group related rules, and include them as a
# whole; it makes explicit the order of the rules, which is quite
# important; and it lets us have both sets of rules general to a whole
# class of host (\emph{e.g.} workstations) and sets of rules specific
# to a single host (\emph{e.g.} \verb!sumo!).
#
class iptables {
    service { "iptables":
        ensure => running,
        hasstatus => true,
    }
# \unimplemented{unixsrg}{GEN003600,GEN003605,GEN003606}{The
# requirement is to drop source-routed IPv4 packets. At SEARDE
# production go-time, the {\tt xtables-addons} package, which
# supplies the iptables match code for IPv4 options, including source
# routing, wasn't working with the rest of iptables. That means
# source-routed packets are not being specifically dropped at the host
# firewall. See~\S\ref{class_network::stig} for another way that most
# of the source-routed traffic is being rejected.}
#
# Our previous means of compliance here has been deleted; see previous
# versions of this file in Subversion.
}

# \implements{unixsrg}{GEN008540} Configure the local firewall to reject all
# packets by default, allowing only by exception.
#
# \implements{unixsrg}{GEN003602,GEN003604} Configure the local firewall to
# reject ICMP timestamp requests, including those sent to a broadcast address.
