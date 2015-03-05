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
# \subsubsection{Disable automatic logout on Macs}

class autologout::no::darwin {
# \implements{macosxstig}{OSX00435 M6}%
# \implements{mlionstig}{OSX8-00-01085}%
# Disable ``automatic logout due to inactivity'' on Macs.
    mac_plist_value { "disable autologout":
        file => "/Library/Preferences/.GlobalPreferences.plist",
        key => "com.apple.autologout.AutoLogOutDelay",
        value => 0,
    }
}
