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
# \subsection{Disable SSH tunnelling features}
#
# This is the subset of STIG-related SSH configuration that is odious.
class ssh::no_tunnelling {
    include ssh
    augeas { "sshd_no_tunnelling":
        context => "/files${ssh::server_config}",
        changes => [
# \implements{unixsrg}{GEN005515} Disallow TCP connection forwarding over SSH,
# because of the ``risk of providing a path to circumvent firewalls and network
# ACLs.''
#
# Note that under the SRG this can be allowed if mitigated. (The sshd\_config
# man page says, ``Note that disabling TCP forwarding does not improve security
# unless users are also denied shell access, as they can always install their
# own forwarders.'' No reply to that from the SRG.)
            "set AllowTcpForwarding no",
# \implements{unixsrg}{GEN005517} Disallow gateway ports.
            "set GatewayPorts no",
# \implements{unixsrg}{GEN005519} Disallow X11 forwarding.
#
# This can also be allowed if mitigated.
            "set X11Forwarding no",
# \implements{unixsrg}{GEN005531} Disallow \verb!tun(4)! device forwarding.
#
# (Wow, I didn't know sshd could do that. Quite cool... except now it's
# disabled.)
            "set PermitTunnel no",
        ],
        notify => Service["sshd"],
    }

# \implements{unixsrg}{GEN005533} Limit connections to a single session.
#
# Lower the session limit per connection. A terminal uses a session,
# and so does a forwarded port or X11 connection. But RHEL5 ssh
# doesn't understand this directive.
    case $::osfamily {
        'RedHat': {
            case $::operatingsystemrelease {
                /^6\./: {
                    augeas { 'sshd_yes_tunnelling_max_sessions':
                        context => "/files${ssh::server_config}",
                        changes => 'set MaxSessions 1',
                        notify => Service['sshd'],
                    }
                }
                /^5\./: {
                    augeas { 'sshd_yes_tunnelling_max_sessions':
                        context => "/files${ssh::server_config}",
                        changes => 'rm MaxSessions',
                        notify => Service['sshd'],
                    }
                }
                default: {}
            }
        }
        default: {}
    }

# The \verb!/etc/ssh/ssh_config! file is parsed by a non-stock lens.
    include augeas

    augeas { "ssh_client_no_tunnelling":
        context => "/files${ssh::server_config}/Host[.='*']",
        changes => [
# \implements{unixsrg}{GEN005516} Disallow TCP forwarding in the client. (See
# above.)
            "set ClearAllForwardings yes",
# \implements{unixsrg}{GEN005518} Disallow gateway ports.
            "set GatewayPorts no",
# \implements{unixsrg}{GEN005520} Disallow X11 forwarding. See above.
            "set ForwardX11 no",
            "set ForwardX11Trusted no",
# \implements{unixsrg}{GEN005532} Disallow \verb!tun(4)! device forwarding.
            "set Tunnel no",
        ],
    }
}
