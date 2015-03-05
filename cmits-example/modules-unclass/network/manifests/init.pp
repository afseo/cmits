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
# \section{Network}

class network {

# Support restarting the network: Other parts of the manifest have
# \verb!notify => Service["network"]!. That refers here.

    service { "network": }

# Anything interested in restarting the network is likely interested in knowing
# about which interfaces we're using on this host.

    include network::interfaces
}

# \bydefault{RHEL6}{unixsrg}{GEN007140,GEN007200,GEN007260,GEN007320,GEN007540,GEN007760}%
# RHEL6 does not appear to provide any packages or loadable kernel modules
# relating to the less-widely-used UDP-Lite, IPX, AppleTalk, DECnet, TIPC or
# NDP protocols.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN007840}%
# RHEL does not run the DHCP client for any interfaces not configured for DHCP,
# i.e. where it is ``not needed.''
#
# The DHCP client is configured not to send dynamic DNS updates, surprisingly,
# in \S\ref{class_eue::dns}. \index{unixsrg}{FIXME}
#
#
# \subsection{Admin guidance regarding networking}
#
# \doneby{admins}{unixsrg}{GEN007820}%
# Don't configure any IP tunnels.
#
