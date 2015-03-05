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
class ntp::darwin {
# \implements{mlionstig}{OSX8-00-00325}%
# Make sure the Mac is using NTP.
    exec { 'enable NTP':
        path => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
        command => 'systemsetup -setusingnetworktime on',
        unless => 'systemsetup -getusingnetworktime | grep On',
    }
# The network time server must also be set; this is site-specific.
}
