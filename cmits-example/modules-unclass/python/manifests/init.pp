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
# \section{Python}
#
# Install Python and whatever is necessary to use eggs.

class python {
    case $osfamily {
        "RedHat": {
            case $operatingsystemrelease {
                /6\..*/: { include python::rhel6 }
                /5\..*/: { include python::rhel5 }
                default: { unimplemented() }
            }
        }
# Python not yet implemented under Darwin.        
        'Darwin': {}
        default: {
            unimplemented()
        }
    }
}
