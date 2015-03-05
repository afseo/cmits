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
# \subsubsection{Login warnings on Snow Leopard}
# \implements{macosxstig}{OSX00100 M6}%
# Configure the Mac OS Snow Leopard login window to show a login
# warning.

class dod_login_warnings::mac_loginwindow::darwin_10_6 {
    mac_default { 'mac_login_warnings':
        domain => '/Library/Preferences/com.apple.loginwindow',
        key => 'LoginwindowText',
        source => 'puppet:///modules/dod_login_warnings/paragraphs',
    }
}
