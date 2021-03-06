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
class network::no_icmp_echo::darwin_10_9 {
# \implements{mlionstig}{OSX8-00-01245}%
# Enable ``Stealth Mode'' on the OSX firewall
    $sffw = '/usr/libexec/ApplicationFirewall/socketfilterfw'
    exec { 'turn on stealth mode':
        command => "${sffw} --setstealthmode on",
        unless => "${sffw} --getstealthmode | grep enabled",
    }
}
