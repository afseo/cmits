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
class swap::encrypt::darwin_10_6 {
# \implements{macosxstig}{OSX00440 M6}%
# ``Use secure virtual memory,'' or in other words, make Macs encrypt their
# swap space.
    $vm = "/Library/Preferences/com.apple.virtualMemory.plist"
# The file may not exist; make sure it has the right ownership and permissions.
    file { $vm:
        ensure => present,
        owner => root, group => admin, mode => 0644,
    }
    mac_plist_value { "encrypt swap":
        require => File[$vm],
        file => $vm,
        key => 'UseEncryptedSwap',
        value => true,
    }
# \implements{mlionstig}{OSX8-00-01260}%
# Use ``secure virtual memory'' on newer Macs.
    mac_plist_value { "un-disable swap encryption":
        require => File[$vm],
        file => $vm,
        key => 'DisableEncryptedSwap',
        value => false,
    }
}
