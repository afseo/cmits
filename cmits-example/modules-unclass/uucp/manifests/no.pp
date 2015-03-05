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
# \subsection{Turn off UUCP}
#
# \unixsrg{GEN005280} requires that UUCP be disabled.

class uucp::no {
    case $::osfamily {
        'redhat': {
            case $::operatingsystemrelease {
# \bydefault{RHEL6}{unixsrg}{GEN005280} RHEL6 does not provide a UUCP service.
                /^6\..*$/: {}
                /^5\..*$/: { package { 'uucp': ensure => absent, } }
            }
        }
# \implements{macosxstig}{GEN005280 M6}%
# \implements{mlionstig}{OSX8-00-00550}%
# Make sure that the UUCP service is disabled.
        'darwin': {
            service { 'com.apple.uucp':
                enable => false,
                ensure => stopped,
            }
        }
        default: { unimplemented() }
    }
}
