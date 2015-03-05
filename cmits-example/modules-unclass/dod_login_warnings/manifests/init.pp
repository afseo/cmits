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
# \section{DoD Login Warnings}
# \label{dod_login_warnings}
#
# Install notice and consent warnings.

class dod_login_warnings {
    case $::osfamily {
        'redhat': {
            include dod_login_warnings::console
            include dod_login_warnings::gdm
            include dod_login_warnings::ssh
        }
        'darwin': {
            include dod_login_warnings::mac_loginwindow
# \implements{macosxstig}{OSX00105 M6}%
# Display login banners when the user ``connects to the computer remotely,''
# via SSH.
#
# ``When a user opens a terminal locally,'' \macosxstig{OSX00105 M6} requires
# that ``the user sees the access warning.'' But opening a terminal on a Mac
# does not constitute logging in to the Mac: the user has already done that,
# and has already been warned by the login window before doing so. Because the
# requirement is to ``display the logon banner \emph{prior} to a logon
# attempt,'' we deviate from the published check and fix content here in order
# to fulfill the spirit of compliance.
            include dod_login_warnings::ssh
        }
        default: {
            include dod_login_warnings::console
            include dod_login_warnings::gdm
            include dod_login_warnings::ssh
        }
    }
}
