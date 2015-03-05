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
# \subsection{ARX workaround}
#
# According to
# \url{http://support.f5.com/kb/en-us/solutions/public/14000/400/sol14478.html?sr=35037786},
# a change was made in RHEL 6.3 to enable more remote procedure calls
# to be in-flight between the client system and an NFS server. The ARX
# is ill-equipped to handle many in-flight RPCs, though, so we must
# limit the RHEL systems back to previous behavior to avoid flooding
# the ARX.

class nfs::arx {
    case $::osfamily {
        'RedHat': {
            file { '/etc/modprobe.d/sunrpc.conf':
                owner => root, group => 0, mode => 0644,
                content => "
options sunrpc tcp_max_slot_table_entries=16
",
            }
        }
        default: {}
    }
}
