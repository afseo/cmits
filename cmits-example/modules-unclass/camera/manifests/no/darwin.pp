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
# \subsubsection{Disable cameras under Mac OS X}

class camera::no::darwin {
    $exts = '/System/Library/Extensions'
    $usbp = "${exts}/IOUSBFamily.kext/Contents/PlugIns"
    file {
# Disable ``support for internal iSight cameras.''
        "${exts}/Apple_iSight.kext":
            ensure => absent,
            force => true;
# Disable ``support for external cameras.''
        "${usbp}/AppleUSBVideoSupport.kext":
            ensure => absent,
            force => true;
    }

# \implements{mlionstig}{OSX8-00-00465}%
# Remove the Photo Booth application.
    file { '/Applications/Photo Booth.app':
        ensure => absent,
        recurse => true,
    }

# \implements{mlionstig}{OSX8-00-00475}%
# Remove the FaceTime application.
    file { '/Applications/FaceTime.app':
        ensure => absent,
        recurse => true,
    }

# \implements{mlionstig}{OSX8-00-00495}%
# Remove the Image Capture application.
    file { '/Applications/Image Capture.app':
        ensure => absent,
        recurse => true,
    }
}
