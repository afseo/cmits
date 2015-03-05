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
# \subsubsection{Disable audio on Macs}

class audio::no::darwin {
# \implements{macosxstig}{OSX00070 M6}%
# \implements{mlionstig}{OSX8-00-01225}%
# Disable audio support where necessary to ``protect the organization's
# privacy.''
    $exts = '/System/Library/Extensions'
    file {
        "${exts}/AppleUSBAudio.kext":
            ensure => absent,
            force => true;
        "${exts}/IOAudioFamily.kext":
            ensure => absent,
            force => true;
    }
}
