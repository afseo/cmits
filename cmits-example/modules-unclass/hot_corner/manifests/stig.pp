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
# \subsection{Prevent users from disabling screensaver}

class hot_corner::stig {

# \implements{macosxstig}{OSX00375 M6}%
# \implements{mlionstig}{OSX8-00-01095}%
# Prevent users from configuring a hot corner to disable the
# screensaver.
#
# Another way to do this besides disabling all hot corners would be to
# force the hot corner configuration to something known to be
# compliant.
    hot_corner {
        'tl': action => 'nothing';
        'tr': action => 'nothing';
        'bl': action => 'nothing';
        'br': action => 'nothing';
    }
}

