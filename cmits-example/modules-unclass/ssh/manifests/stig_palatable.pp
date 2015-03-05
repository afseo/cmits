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
# \subsection{Palatable STIG-compliant configuration}
#
# More than half of these settings are defaults built into OpenSSH, but if they
# are in the Puppet policy, we gain the guarantee of continuing compliance.
#
# All of these settings are bearable; the unbearable ones are in
# \S\ref{class_ssh::no_tunnelling}.

class ssh::stig_palatable {
    include ssh

    augeas { "sshd_stig":
        context => "/files${ssh::server_config}",
        changes => [
# \index{unixsrg}{GEN001020!over SSH|see{GEN001120}}
#
# \implements{unixsrg}{GEN001020,GEN001100,GEN001120}%
# \implements{macosxstig}{OSX00165 M6}%
# \implements{mlionstig}{OSX8-00-00565}%
# Disallow root login over {\tt ssh}: admins must use {\tt su}
# (\S\ref{module_su}) or {\tt sudo} after logging in as themselves.
            "set PermitRootLogin no",
# \implements{unixsrg}{GEN002040}%
# Ignore per-user \verb!.rhosts! and \verb!.shosts! files.
            "set IgnoreRhosts yes",
# \implements{unixsrg}{GEN002040}%
# Make sure host-based authentication is not used.
#
# (\verb!RhostsRSAAuthentication! would need to be turned off, but it's
# only valid for protocol 1 and we just forced protocol 2 above.)
            "set HostbasedAuthentication no",
# \implements{unixsrg}{GEN005526}%
# Disable Kerberos authentication in the SSH server ``unless needed.'' We do
# not need it.
            "set KerberosAuthentication no",
# \implements{unixsrg}{GEN005528}%
# Don't accept any environment variables from the client.
#
# RHEL default settings only accept locale-related environment variables; our
# policy here is just defense in depth.
            "rm AcceptEnv",
# \implements{unixsrg}{GEN005530}%
# Disallow environment settings set by the user and applied by the SSH server.
#
# Don't process requests for environment
# variables coming from \verb!~/.ssh/environment! or \verb!environment=!
# sections in \verb!~/.ssh/authorized_keys!, because a malicious user could try
# to set \verb!LD_PRELOAD!, causing unexpected behavior.
            "set PermitUserEnvironment no",
# \implements{unixsrg}{GEN005536}%
# Cause the SSH server to ignore any user-specific files (\emph{e.g.},
# \verb!known_hosts!, \verb!authorized_keys!) that are not under the strict
# control of that user.
            "set StrictModes yes",
# \implements{unixsrg}{GEN005537}%
# Use OpenSSH's privilege separation feature for better security.
            "set UsePrivilegeSeparation yes",
# \implements{unixsrg}{GEN005538}%
            "set RhostsRSAAuthentication no",
# \implements{unixsrg}{GEN005539}%
            "set Compression delayed",
        ],
        notify => Service["sshd"],
    }

# The \verb!/etc/ssh/ssh_config! file is parsed by a non-stock lens.
    include augeas

    augeas { "ssh_client_stig":
        context => "/files${ssh::client_config}/Host[.='*']",
        changes => [
# \notapplicable{unixsrg}{GEN005527}%
# No way to disable Kerberos authentication in the stock OpenSSH client is
# listed in the \verb!man! page.
#
# \bydefault{RHEL6}{unixsrg}{GEN005529}%
# RHEL default settings only send locale-related environment variables.
        ],
    }

# \implements{unixsrg}{GEN005522}%
# Restrict write permissions on the public SSH host keys.
    file {
        "${ssh::configdir}/ssh_host_key.pub":
            owner => root, group => 0, mode => 0644;
        "${ssh::configdir}/ssh_host_rsa_key.pub":
            owner => root, group => 0, mode => 0644;
        "${ssh::configdir}/ssh_host_dsa_key.pub":
            owner => root, group => 0, mode => 0644;
    }
# \implements{unixsrg}{GEN005523}%
# Restrict reading and writing permissions on the private SSH host keys.
    file {
        "${ssh::configdir}/ssh_host_key":
            owner => root, group => 0, mode => 0600;
        "${ssh::configdir}/ssh_host_rsa_key":
            owner => root, group => 0, mode => 0600;
        "${ssh::configdir}/ssh_host_dsa_key":
            owner => root, group => 0, mode => 0600;
    }
}
