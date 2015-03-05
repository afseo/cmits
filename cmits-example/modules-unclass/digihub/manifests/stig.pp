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
# \section{STIG-required digihub configuration}

class digihub::stig {

    $dh = 'com.apple.digihub'

# \implements{macosxstig}{OSX00340 M6}%
# \implements{mlionstig}{OSX8-00-00085}%
# Disable automatic actions when blank CDs are inserted.
#
# We don't strictly conform with the check and fix text here, because this is a
# Category I requirement, but the check and fix may only fix the systemwide
# default settings, not enforce the settings on everyone.
    mcx::set { "${dh}/${dh}.blank.cd.appeared":
        value => 1,
    }

# \implements{macosxstig}{OSX00341 M6}%
# \implements{mlionstig}{OSX8-00-00090}%
# Disable automatic actions when blank DVDs are inserted.
#
# Same as above.
    mcx::set { "${dh}/${dh}.blank.dvd.appeared":
        value => 1,
    }

# \implements{macosxstig}{OSX00345}%
# \implements{mlionstig}{OSX8-00-00095}%
# Disable automatic actions when music CDs are inserted.
#
# Here the STIG check and fix text have to do with setting things in the System
# Preferences GUI. With our MCX mechanism we are enforcing policies regarding
# these preferences; this is the only way to be sure because these preferences
# are stored and changed on a per-user basis, so setting the local admin user's
# preference to ``do nothing'' does not influence the value of any other user's
# preference. But setting the MCX policy forces the values of these preferences
# for everyone on the computer.
    mcx::set { "${dh}/${dh}.cd.music.appeared":
        value => 1,
    }

# \implements{macosxstig}{OSX00350 M6}%
# \implements{mlionstig}{OSX8-00-00100}%
# Disable automatic actions when picture CDs are inserted.
    mcx::set { "${dh}/${dh}.cd.picture.appeared":
        value => 1,
    }

# \implements{macosxstig}{OSX00355 M6}%
# \implements{mlionstig}{OSX8-00-00105}%
# Disable automatic actions when video DVDs are inserted.
    mcx::set { "${dh}/${dh}.dvd.video.appeared":
        value => 1,
    }
}
