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
# \subsection{Disallow admins from unlocking user screens}
#
# \implements{macosxstig}{OSX00200 M6}%
# \implements{mlionstig}{OSX8-00-00935}%
# Disable administrative accounts from unlocking other users' screens.
#
# Mac OS X has a setting which when turned on lets not only the user who locked
# the screen unlock it, but also any admin. The STIG requires that this setting
# be turned off. Admins are still able to unlock their own screens, just not
# those of other users.

class screensaver::no_admin_unlock {
    case $::macosx_productversion_major {
        "10.6": {
            mac_plist_value { 'disable_admin_screensaver_unlock':
                file => '/etc/authorization',
                key => ['rights', 'system.login.screensaver', 'rule'],
                value => 'authenticate-session-owner',
            }
        }
        "10.9": {
            mac_authz_plist_value { 'no admin unlock screensaver':
                right => 'system.login.screensaver',
                key => ['rule'],
                value => ['authenticate-session-owner', ''],
            }
        }
        default: { unimplemented() }
    }
}

