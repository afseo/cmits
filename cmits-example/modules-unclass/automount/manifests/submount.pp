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
# \subsection{Define mounts under subdirectories}
#
# Whatever you give as the under value for this define, you must have
# an \verb!automount::subdir! define for.
# See~\S\ref{define_automount::subdir}
# and~\S\ref{define_automount::mount}.

define automount::submount($under, $from, $ensure='present') {
    include automount

    case $::osfamily {
        'redhat': {
            automount::mount::redhat { $name:
                from => $from,
                under => $under,
                ensure => $ensure,
            }
        }
        'darwin': {
# \implements{unixsrg}{GEN002420,GEN005900} Ensure the \verb!nosuid! option
# is used when mounting an NFS filesystem.
#
# \implements{unixsrg}{GEN002430} Ensure the \verb!nodev! option is used when
# mounting an NFS filesystem.
            mac_automount { "/net/${under}/${name}":
                source => $from,
                ensure => $ensure,
                options => ['nodev', 'nosuid', 'nolock'],
                notify => Service['com.apple.autofsd'],
            }
        }
        default: { unimplemented() }
    }
}
