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
# \subsection{STIG-required configuration}
#
# Configure the Mac screensaver as required by the Mac OS X STIG.

class screensaver::stig {
    include screensaver::public_pattern
    include screensaver::no_admin_unlock
# \implements{macosxstig}{OSX00360 M6}%
# \implements{mlionstig}{OSX8-00-00010}%
# Set the screensaver idle timeout to ``15 minutes or less.''
    class { 'screensaver::timeout':
        seconds => 900,
    }
# Implied by the rule title of \macosxstig{OSX00360 M6} but not covered by the
# check and fix content is that the screensaver must require authentication to
# unlock.
    include screensaver::authenticate
}
