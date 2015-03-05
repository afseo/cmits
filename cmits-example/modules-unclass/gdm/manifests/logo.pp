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
# \subsection{Login prompt logos}
#
# Configure GDM to show an organization's logo at the login prompt.
#
# The \verb!source! parameter is used to fetch the image files for the logo. It
# specifies a Puppet module and directory inside which image files for the logo
# can be found. As an example, if you write
# \begin{verbatim}
#   class { 'gdm::logo':
#       source => 'puppet:///modules/gdm/logo/afseo',
#   }
# \end{verbatim}
# then files will be copied from \verb!puppet:///modules/gdm/logo/afseo! to
# places under \verb!/usr/share/icons!. The files placed in the manifest should
# go in the \verb!gdm/files/logo/afseo! directory. Inside that directory there
# should be a \verb!logo-48x48.png! file and a \verb!logo-scalable.png! file.
#
# For more details and explanation, consult the governing standards:
# \href{Installing
# Icons}{http://developer.gnome.org/integration-guide/stable/icons.html.en},
# \href{freedesktop.org Icon Naming
# Spec}{http://standards.freedesktop.org/icon-naming-spec/latest/}, and
# \href{freedesktop.org Icon Theme
# Spec}{http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html}.

class gdm::logo($source) {
    if($gdm_installed == 'true') {
        case $osfamily {
            RedHat: {
                case $operatingsystemrelease {
                    /^6\..*/: {
                        class { 'gdm::logo::rhel6':
                            source => $source,
                        }
                    }
                    /^5\..*/: {
                        class { 'gdm::logo::rhel5':
                            source => $source,
                        }
                    }
                    default: { unimplemented() }
                }
            }
            default: { unimplemented() }
        }
    }
}
