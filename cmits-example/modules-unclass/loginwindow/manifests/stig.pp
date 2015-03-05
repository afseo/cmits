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
# \subsection{STIG-required login window configuration}

class loginwindow::stig {

    $lw_domain = "/Library/Preferences/com.apple.loginwindow"

# \implements{macosxstig}{OSX00310 M6}%
# Configure the Mac login window to show username and password prompts, not a
# ``list of local user names available for logon.''
    mac_default { "$lw_domain:SHOWFULLNAME":
        type => int,
        value => 1,
    }

# \implements{macosxstig}{OSX00325 M6}%
# Disable password hints in the Mac login window.
    mac_default { "$lw_domain:RetriesUntilHint":
        type => int,
        value => 0,
    }

# \implements{macosxstig}{OSX00425 M6}%
# Disable automatic login on Macs.
    mac_default { "$lw_domain:autoLoginUser":
        ensure => absent,
    }
}
