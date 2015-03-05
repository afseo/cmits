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
# \subsection{Remove unnecessary users}
#
# \implements{unixsrg}{GEN000290} Remove ``application accounts for
# applications not installed on the system.''
#
# The set of needed system users varies by operating system and release; so,
# likewise, does the set of unnecessary system users.

class user::unnecessary {
    case $osfamily {
        RedHat: {
            case $operatingsystemrelease {
                /^6.*/: { include user::unnecessary::rhel6 }
                /^5.*/: { include user::unnecessary::rhel5 }
                default: { unimplemented() }
            }
        }
        Darwin: {}
        default: { unimplemented() }
    }
}
