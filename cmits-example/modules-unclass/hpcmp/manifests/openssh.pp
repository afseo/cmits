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
# \subsection{OpenSSH}
#
# Configuration necessary to connect to an HPCMP-administered cluster.
#
# The parameter \verb!hpc_cluster_host_patterns! is one or a list of host
# patterns as defined in \verb!ssh_config(1)!, to which client-side SSH
# settings will apply. The host patterns should match any HPCMP cluster login
# node, but should not match local hosts.

class hpcmp::openssh($hpc_cluster_host_patterns) {
    include hpcmp::kerberos
    include "hpcmp::openssh::${::osfamily}"

# This define implements for a set of hosts some of the settings Vern Staats
# set out on 1 May 2012. In the original configuration they are applied to all
# hosts. But we may need different settings, and so these settings should only
# apply when connecting to an HPCMP cluster.
#
# Some of the original configurations Vern specified are now part of the
# \verb!ssh::fips! class, \S\ref{class_ssh::fips}, and so are not written here.

    define vrs_settings() {
        require augeas
        augeas { "hpcmp_ssh_config_add_${name}":
            context => "/files${ssh::client_config}",
            onlyif =>
"match Host[.='${name}'] size == 0",
            changes => [
                "set Host[999] '${name}'",
            ],
        }

        augeas { "hpcmp_ssh_config_config_${name}":
            require => [
                Augeas["hpcmp_ssh_config_add_${name}"],
                Package['hpc_ossh'],
                ],
            context =>
"/files${ssh::client_config}/Host[.='${name}']",
            changes => [
                'set GSSAPIAuthentication yes',
                'set GSSAPIDelegateCredentials yes',
                'set GSSAPIKeyExchange yes',
                'set GSSAPIRenewalForcesRekey yes',
                "set PreferredAuthentications \
gssapi-with-mic,external-keyx,publickey,\
hostbased,keyboard-interactive,password",
                'set ForwardX11 yes',
                'set ForwardX11Trusted no',
# The Unix SRG prevents us from using SSH forwarding everywhere
# (see~\S\ref{class_ssh::no_tunnelling}), but for HPCMP clusters we need it,
# and apparently the HPCMP has accepted the risk, because their distribution of
# OpenSSH comes with it enabled. So un-disable it when talking to HPCMP
# clusters.
                'set ClearAllForwardings no',
# Get rid of some settings, which when implemented here cause ssh to groan and
# fail.
                'rm NoneEnabled',
                'rm MaxSessions',
                'rm XAuthLocation',
                'rm TcpRcvBuf',
                'rm TcpRcvBufPoll',
                'rm UMask',
            ],
        }
    }

    vrs_settings { $hpc_cluster_host_patterns: }
}
