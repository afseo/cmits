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
class call_home::no::darwin_10_9 {
# \implements{mlionstig}{OSX8-00-00531}%
# Disable ``Find My Mac.''
    service { 'com.apple.findmymacd':
        ensure => stopped,
        enable => false,
    }

# \implements{mlionstig}{OSX8-00-00532}%
# Disable the ``Find My Mac'' messenger.
    service { 'com.apple.findmymacmessenger':
        ensure => stopped,
        enable => false,
    }

# \implements{mlionstig}{OSX8-00-00530}%
# Disable the sending of diagnostic and usage data to Apple.
    $lascr = '/Library/Application Support/CrashReporter'
    mac_plist_value { 'turn off AutoSubmit':
        file => "${lascr}/DiagnosticMessagesHistory.plist",
        key => 'AutoSubmit',
        value => false,
    }
}
