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
# \paragraph{Disable Bluetooth under Mac OS X}
#
# \implements{macosxstig}{OSX00065 M6}%
# \implements{mlionstig}{OSX8-00-00060,OSX8-00-00065,OSX8-00-00080}%
# Disable and/or uninstall Bluetooth protocol on Macs.

class network::bluetooth::no::darwin {
    $exts = '/System/Library/Extensions'
    file {
        "${exts}/IOBluetoothFamily.kext":
            ensure => absent,
            force => true;
        "${exts}/IOBluetoothHIDDriver.kext":
            ensure => absent,
            force => true;
    }
}
