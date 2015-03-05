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
# \subsection{Notice of monitoring via graphical login}
#
# \implements{unixsrg}{GEN000402} Show a warning before the login box under
# GDM.
#
# This would normally go under~\S\ref{class_gdm}, but because the text of the
# warning is of legal import and we are inspected on it yearly, it's better to
# keep everything that uses the warning text in one place.

class dod_login_warnings::gdm {

# First, do no harm.
    if($gdm_installed == 'true') {

# RHEL5 and RHEL6 show the banner differently.
        case $osfamily {
            'RedHat': {
                case $operatingsystemrelease {
                    /^6\..*/: {
                        include dod_login_warnings::gdm::rhel6
                    }
                    /^5\..*/: {
                        include dod_login_warnings::gdm::rhel5
                    }
                    default: { unimplemented() }
                }
            }
            default: { unimplemented() }
        }
    }
}
