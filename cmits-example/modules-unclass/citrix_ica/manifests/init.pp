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
# \section{Citrix Receiver ICA client}
#
# Some users may require access to the Citrix XenApp server via the
# Citrix Receiver ICA client.
#
# The ICAClient package is not part of RHEL: it must be fetched from
# Citrix. But the package fetched from Citrix is signed using the MD5
# digest algorithm, and so will not install on a host configured for
# FIPS 140-2 compliance (see~\S\ref{module_fips}). So we have a custom
# package, the same in every salient respect except that it is signed
# using SHA256.

class citrix_ica {
    case $::osfamily {
        'RedHat': {
            package { 'ICAClient':
                ensure => '12.1.0.203066-1SK02',
            }
            mozilla::wrap_32bit { 'npica.so':
                require => Package['ICAClient'],
            }
        }
        'Darwin': { warning("citrix_ica not yet implemented on Macs") }
        default: { unimplemented() }
    }
    include pki::ca_certs::citrix_receiver
}
