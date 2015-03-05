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
# \subsection{Remove a previous group allowance}
#
# Stop letting members of a UNIX group use USB mass storage without
# authenticating as admins.
#
# Note that this does not explicitly disallow them: it merely undoes what
# \verb!usb::mass_storage::allow_group! does. That's why this is not called
# \verb!disallow_group!.
#
# Usage example:
# \begin{verbatim}
#     usb::mass_storage::unallow_group { "accounting": }
# \end{verbatim}
# \dinkus

define usb::mass_storage::unallow_group() {
    $group = $name
    case $osfamily {
        RedHat: {
            case $operatingsystemrelease {

                /^6\..*/: {
    file { "/etc/polkit-1/localauthority/90-mandatory.d/\
60-mil.af.eglin.afseo.group-${group}-udisks.pkla":
            ensure => absent,
    }
                }

                /^5\..*/: {
    unimplemented()
                }

                default: { unimplemented() }
            }
        }
        default: { unimplemented() }
    }
}
