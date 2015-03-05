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
# \subsection{Startup file permissions}

class stig_misc::startup_files {
    case $osfamily {
# The Mac OS X STIG check content and fix text fails to delineate ``system
# start-up files'' any more specifically than ``every file on the root
# volume.''
        'darwin': { include stig_misc::vendor_permissions }
# The RHEL 5 STIG check content and fix text defines ``system start-up files''
# to be the same set of files as ``run control scripts.''
        'redhat': { include stig_misc::run_control_scripts }
        default:  { unimplemented() }
    }
}
