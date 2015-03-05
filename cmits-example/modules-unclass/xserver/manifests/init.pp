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
# \section{X Window System server}
#
# Make sure an X server is installed.
#
# The NVIDIA proprietary drivers need the X server installed, but it may be
# surprising for the \verb!nvidia::proprietary! class to silently install an X
# server. So we install it here.

class xserver {
    case $::osfamily {
        'RedHat': {
            case $::operatingsystemrelease {
                /^[56]\..*$/: {
                    package { 'xorg-x11-server-Xorg':
                        ensure => present,
                    }
                }
                default: { unimplemented() }
            }
        }
        'Darwin': {}
        default: { unimplemented() }
    }
}
