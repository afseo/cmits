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
# \subsection{Remove user list}
#
# Prevent GDM from showing a list of possible users to log in as.

class gdm::no_user_list {
    if($gdm_installed == 'true') {
        case $osfamily {
            RedHat: {
                case $operatingsystemrelease {
                    /^6\..*/: {
                        include gdm::no_user_list::rhel6
                    }
# GDM 2 (RHEL5) doesn't do user lists.
                    /^5\..*/: { }
                    default: { unimplemented() }
                }
            }
            default: { unimplemented() }
        }
    }
}
