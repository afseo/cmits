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
# \subsection{STIG-required Samba configuration}
#
# Even though we aren't using Samba, any remaining configuration files are
# subject to STIG requirements.
#
class samba::stig {
    case $::osfamily {
        'redhat': { include samba::stig::redhat }
        'darwin': { include samba::stig::darwin }
        default:  { unimplemented() }
    }
}
