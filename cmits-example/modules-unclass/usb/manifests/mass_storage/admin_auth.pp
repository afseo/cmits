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
# \subsection{Require admin password for USB storage}
#
# \implements{unixsrg}{GEN008480} Prevent installation of malicious software or
# exfiltration of data by restricting the use of mass storage to administrators.
#
# (USB mass storage could be disabled entirely from desktop use, but
# admins can become root and use the mount command anyway. As long as we trust
# our vendor to give us correct software, there's no particular advantage in
# slashing a swath of nonfunctionality through the desktop.)
class usb::mass_storage::admin_auth {
    case $osfamily {
        RedHat: {
            case $operatingsystemrelease {

                /^6\..*/: {
    file { "/etc/polkit-1/localauthority/90-mandatory.d/\
50-mil.af.eglin.afseo.admin-udisks.pkla":
        owner => root, group => 0, mode => 0600,
        source => "puppet:///modules/usb/mass_storage/\
admin-udisks.pkla",
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
