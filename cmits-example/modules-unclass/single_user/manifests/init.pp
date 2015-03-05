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
# \section{Control access to single-user mode}
# Different operating systems do this differently; so first we must pick an
# implementation.
#
# \implements{iacontrol}{DCSS-1} Control access to single-user mode, so that
# ``system initialization'' and ``shutdown... are configured to ensure that the
# system remains in a secure state.''

class single_user {
    case $osfamily {
        RedHat: {
            case $operatingsystemrelease {
                /^6.*/: {
                    include single_user::rhel6
                }
                /^5.*/: {
                    include single_user::rhel5
                }
                default: { unimplemented() }
            }
        }
# \doneby{admins}{iacontrol}{DCSS-1}%
# Under Mac OS X, single-user mode access is controlled by a boot
# password, which must be set from a utility which is run from the Mac
# OS X install disk. This cannot be automated.
        Darwin: {}
        default: { unimplemented() }
    }
}
