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
# \section{Smartcards}
#
# Configure smart card drivers and support.
#
# Application-specific settings may also be necessary.

class smartcard {
    case $::osfamily {
        'RedHat': {
            package { ['pcsc-lite', 'coolkey']:
                ensure => present,
            }
        }
        'Darwin': {
            case $::macosx_productversion_major {
                '10.6': {
                    mac_package { 'OpenSC-0.12.2-10.6-1.dmg':
                        ensure => installed,
                    }
                }
                '10.9': {
                    mac_package { 'OpenSC-0.12.2-10.9hack.dmg':
                        ensure => installed,
                    }
                }
                default: { unimplemented() }
            }
        }
        default: { unimplemented() }
    }
}

