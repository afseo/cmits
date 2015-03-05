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
# \subsection{Wrap 32-bit plugins}
#
# This defined resource type makes sure a 32-bit Mozilla plugin is wrapped on
# 64-bit hosts. 32-bit plugins that come from Red Hat (e.g.,
# \verb!flash-plugin!) will do this themselves, but plugins from other vendors
# may not.
#
# To use this resource type, first get the 32-bit plugin installed, under
# \verb!/usr/lib/mozilla/plugins!, the place for 32-bit browser plugins under
# Red Hat-family Linuxen. Then make a resource of this type, whose name is the
# name of the plugin file.
#
# Example:
# \begin{verbatim}
#     mozilla::wrap_32bit { 'npica.so': }
# \end{verbatim}
# \dinkus

define mozilla::wrap_32bit {
    require mozilla::wrap_32bit::prerequisites
    case $::osfamily {
        'RedHat': {
            $thirtytwo_dir = "/usr/lib/mozilla/plugins"
            $wrapped_dir   = "/usr/lib64/mozilla/plugins-wrapped"
            case $::architecture {
                'x86_64': {
                    exec { "wrap_32bit_${name}":
                        onlyif => "test -f ${thirtytwo_dir}/${name}",
                        command => "mozilla-plugin-config -i",
                        creates => "${wrapped_dir}/nswrapper_32_64.${name}",
                    }
                }
                'i386': {}
                default: { unimplemented() }
            }
        }
        default: { unimplemented() }
    }
}
