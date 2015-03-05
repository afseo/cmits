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
# \section{Graphical login}
#
# Some hosts should have graphical login. Others should not. This class enables
# or disables that feature.
#
# This class only turns graphical login on or off; it does not apply
# STIG-related requirements to the mechanism of graphical login.
# See~\S\ref{module_gdm} for that.

class graphical_login {
    case $::osfamily {
        'RedHat': {
            package { 'gdm':
                ensure => installed,
            }
# Fortunately this is the one thing RHEL5 and RHEL6 have in common
# between their init systems.
            augeas { 'default_runlevel_5':
                context => '/files/etc/inittab',
                changes => 'set id/runlevels 5',
            }
        }
# Mac OS X always has graphical login.        
        'Darwin': {}
        default: { unimplemented() }
    }
}
