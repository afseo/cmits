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
# \section{Fast user switching}
#
# Enable fast user switching on the Mac. This contravenes 
# \macosxstig{OSX00330 M6}.
#
# The \verb!menu_style! parameter can have values ``Name,'' ``Short Name'' or
# ``Icon.''

class fast_user_switching($menu_style='Name')  {
    $fus_domain = '/Library/Preferences/.GlobalPreferences'
    mac_default { "$fus_domain:MultipleSessionEnabled":
        type => bool,
        value => true,
    }

    mac_default { "$fus_domain:userMenuExtraStyle":
        type => int,
        value => $menu_style ? {
            'Name' => 0,
            'Short Name' => 1,
            'Icon' => 2,
            default => fail("unknown fast user switching \
menu style $menu_style"),
        },
    }
}
