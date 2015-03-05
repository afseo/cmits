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
# \subsection{Force permissions specified by vendors}
#
# \implements{macosxstig}{GEN001660 M6,GEN001680 M6}%
# To make sure all ``system start-up files'' are properly owned and group-owned
# on the Mac, run the disk utility to ``reset the ownership to the original
# installation settings.''
#
# \implements{macosxstig}{GEN006565 M6,GEN006570 M6,GEN006571 M6}%
# ``Verify system software periodically,'' including the ACLs of files and
# their extended attributes.

class stig_misc::vendor_permissions {
    case $osfamily {
        'darwin': {
            exec { 'startup_file_permissions':
                command => "/usr/sbin/diskutil \
                            repairPermissions /",
                loglevel => warning,
            }
        }
        default: { unimplemented() }
    }
}
