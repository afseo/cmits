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
# \subsubsection{Citrix Receiver ICA clients}
#
# Install CA certs into the proper directory where they can be used by the
# Citrix Receiver ICA client.
#
# It appears that the ICA client only needs the root certificate.

class pki::ca_certs::citrix_receiver {
    define install($cacerts) {
        file { "$cacerts/$name":
            owner => root, group => 0, mode => 0444,
            source => "puppet:///modules/pki/all-ca-certs/$name",
        }
    }
    case $::osfamily {
        'RedHat': {
            install { 'DoD-Root2-Root.crt':
                cacerts => '/opt/Citrix/ICAClient/keystore/cacerts',
            }
        }
        default: {
            notify { "unimplemented on $::osfamily": }
        }
    }
}
