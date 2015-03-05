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
# \subsection{Disable WiFi on Macs}

class network::wifi::no::darwin {

# \implements{macosxstig}{OSX00060 M6}%
# Disable Wi-Fi on Macs by removing the driver files that support it.
    $exts = '/System/Library/Extensions'
    file { "${exts}/IO80211Family.kext":
        ensure => absent,
        force => true,
    }

    $nse = 'networkserviceenabled'
    exec { 'disable AirPort network service':
        command => 'networksetup -set${nse} AirPort off',
        onlyif => 'networksetup -get${nse} | grep Enabled',
    }
    exec { 'disable Wi-Fi network service':
        command => 'networksetup -set${nse} Wi-Fi off',
        onlyif => 'networksetup -get${nse} | grep Enabled',
    }

# \implements{macosxstig}{OSX00385 M6}%
# Turn off AirPort power on Macs if ``unused.''
#
# This one is a little tricky because you have to give a network
# interface name, not a network service name. And it's theoretically
# possible for a network service to own multiple interfaces.
    exec { 'turn off AirPort power':
# So---if any Wi-Fi or AirPort devices have power On...
        onlyif => "\
              networksetup -listnetworkserviceorder | \
              grep -A1 'Wi-Fi\\|AirPort' | \
              grep -o 'Device: [a-z0-9]\\+' | \
              cut -d: -f2 | \
              xargs -n 1 networksetup -getairportpower | \
              grep 'On\$'",
# ...turn off power to all Wi-Fi or AirPort devices.
        command => "\
              networksetup -listnetworkserviceorder | \
              grep -A1 'Wi-Fi\\|AirPort' | \
              grep -o 'Device: [a-z0-9]\\+' | \
              cut -d: -f2 | \
              xargs -I % networksetup -setairportpower % Off",
    }

This is done using System Preferences. Open the Network section;
for each active AirPort interface in the pane on the left, click the
interface, and click ``Turn AirPort Off.'' After all of this, click
``Apply.''

This is done using System Preferences.
\doneby{admins}{macosxstig}{OSX00400 M6}%
Turn off IPv6 on Macs ``if not being used.''

This is done using System Preferences. Open the Network section;
for each active interface in the pane on the left, click the interface,
click the ``Advanced...'' button toward the lower right, and in the TCP/IP
tab, change the ``Configure IPv6'' setting to ``Off.'' After all of this,
click ``Apply.''
}
