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
# \section{NFS version 3}
# Most NFS filesystems are mounted using the automounter; see
# \ref{define_automount::mount} and look in the Defined Resource Types index.
#
# To use NFSv3 we must do remote procedure calls (RPC). This requires a
# portmapper or binder; under RHEL5 this is called \verb!portmap! and under
# RHEL6 it is \verb!rpcbind!.
#
# There's also a statd and maybe a lockd which need to be installed and
# running, which are contacted via RPC.

class nfs {
# In \S\ref{module_gdm}, the pieces of policy for each OS and version are split
# out into separate files. Here they are all written in two big case
# statements. For further implementations, decide which is simpler and better.

    case $osfamily {
        RedHat: {
            $portmap = $operatingsystemrelease ? {
                /^6.*/ => "rpcbind",
                /^5.*/ => "portmap",
                default => unimplemented(),
            }
            package { $portmap: ensure => present }
            tcp_wrappers::allow { $portmap:
                from => "127.0.0.1",
            }
            service { $portmap:
                require => [
                    Package[$portmap],
                    Tcp_wrappers::Allow[$portmap],
                ],
                enable => true,
                ensure => running,
            }

            package { "nfs-utils":
                require => Package[$portmap],
                ensure => present,
            }
            service { "nfslock":
                require => [
                    Service[$portmap],
                    Package["nfs-utils"],
                ],
                enable => true,
                ensure => running,
            }
        }
# Mac OS X Snow Leopard is rather more monolithically installed, and comes with
# NFS support.
        darwin: {}
        default: { unimplemented() }
    }
}
