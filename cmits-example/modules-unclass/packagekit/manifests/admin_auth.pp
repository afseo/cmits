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
# \subsection{Require admin authentication}
#
# Keep normal users from installing or removing software.

class packagekit::admin_auth {
    case $osfamily {
        RedHat: {
            case $operatingsystemrelease {

                /^6\..*/: {

# Get rid of the pre-\verb!policykit::rule! file.
                        file {
"/etc/polkit-1/localauthority/90-mandatory.d/\
50-mil.af.eglin.afseo.admin-packagekit.pkla":
                            ensure => absent,
                        }

                        policykit::rule { 'admin-packagekit':
                            description =>
'require admin authn for package actions',
                            identity => '*',
                            action =>
'org.freedesktop.packagekit.*',
                        }
                }

# RHEL5 includes neither PackageKit nor PolicyKit, so users already can't
# install or remove software without admin privileges.
                /^5\..*/: {}

                default: { unimplemented() }
            }
        }
    }
}
