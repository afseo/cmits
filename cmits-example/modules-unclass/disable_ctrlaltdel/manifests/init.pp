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
# \section{Disable Ctrl-Alt-Del at console}
# \label{disable_ctrlaltdel}
#
# \implements{rhel5stig}{GEN000000-LNX00580}%
# \implements{iacontrol}{DCSS-1} Ensure that ``shutdowns'' are ``configured to
# ensure that the system remains in a secure state'' by preventing an
# unauthenticated person at the console from rebooting the system.

class disable_ctrlaltdel {
    case $::osfamily {
        'RedHat': {
            case $::operatingsystemrelease {
                /^6\..*/: { require disable_ctrlaltdel::rhel6 }
                /^5\..*/: { require disable_ctrlaltdel::rhel5 }
                default:  { unimplemented() }
            }
        }
        default: { unimplemented() }
    }
}
