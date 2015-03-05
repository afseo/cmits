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
# \subsubsection{Disable rsh, rlogin, and rexec under Mac OS X}

class rsh::no::darwin {
# \implements{macosxstig}{GEN003820 M6}%
# \implements{mlionstig}{OSX8-00-00050}%
# Make sure the rsh daemon is not running.
    service { 'com.apple.rshd':
        enable => false,
        ensure => stopped,
    }
# \implements{macosxstig}{GEN003840 M6}%
# \implements{mlionstig}{OSX8-00-00035}%
# Make sure the rexec daemon is not running.
    service { 'com.apple.rexecd':
        enable => false,
        ensure => stopped,
    }
# \implements{macosxstig}{GEN003850 M6}%
# \implements{mlionstig}{OSX8-00-00040}%
# Make sure the telnet daemon is not running.
    service { 'com.apple.telnetd':
        enable => false,
        ensure => stopped,
    }
# \implements{macosxstig}{GEN003860 M6}%
# \implements{mlionstig}{OSX8-00-01115}%
# Make sure the finger daemon is not running.
    service { 'com.apple.fingerd':
        enable => false,
        ensure => stopped,
    }
}
