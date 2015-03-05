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
# \subsection{STIG-required configuration}
#
# The way to configure GDM and the X servers it starts varies between RHEL5 and
# RHEL6.

class gdm::stig {
    if($gdm_installed == 'true') {
        case $osfamily {
            RedHat: {
                case $operatingsystemrelease {
                    /^6.*/: { include gdm::stig::rhel6 }
                    /^5.*/: { include gdm::stig::rhel5 }
                    default: { unimplemented() }
                }
            }
            default: { unimplemented() }
        }
    }
}
