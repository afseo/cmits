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
# \subsection{Require authentication to exit screensaver}

class screensaver::authenticate {

# \implements{macosxstig}{OSX00360 M6,OSX00420 M6}%
# \implements{mlionstig}{OSX8-00-00020}%
# Password-protect Mac screensavers.
#
# This requirement is in the rule title of \macosxstig{OSX00360 M6}, but not in
# the check or fix content. \macosxstig{OSX00420 M6} directly requires it.
    mcx::set {
        'com.apple.screensaver/askForPassword':
            value => 1;
        'com.apple.screensaver/askForPasswordDelay':
            value => 0;
    }
}
