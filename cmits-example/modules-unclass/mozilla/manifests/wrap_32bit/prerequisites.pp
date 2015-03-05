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
# \subsubsection{Prerequisites for wrapping 32-bit Mozilla plugins}

class mozilla::wrap_32bit::prerequisites {
    case $::osfamily {
        'RedHat': {
            case $::architecture {
                'x86_64': {
# The package containing the plugin may not know about all the prerequisites
# necessary for it to happen, so it may not pull them in when it's installed.
# We list them here so they will certainly be installed.
                    package { [
                        'nspluginwrapper.i686',
                        'nspluginwrapper.x86_64',
                        'zlib.i686',
# Without these, the Flash plugin and Citrix ICA receiver plugin have
# successfully installed, but failed to actually run under nspluginwrapper.
                        'libcanberra-gtk2.i686',
                        'PackageKit-gtk-module.i686',
                        'gtk2-engines.i686',
                    ]:
                        ensure => present,
                    }
                }
# No wrapping is necessary for 32-bit plugins on a 32-bit system. 
                'i386': {}
                default: { unimplemented() }
            }
        }
        default: { unimplemented() }
    }
}
