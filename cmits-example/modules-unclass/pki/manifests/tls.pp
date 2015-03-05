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
# \subsection{TLS}
#
# Maintain certificates, keys, and CRLs needed for TLS (Transport Layer
# Security). These are used by web servers.

class pki::tls($http_proxy='') {
# Make sure the private TLS directory is actually private.
    file { "/etc/pki/tls/private":
        owner => root, group => 0, mode => 0600,
        recurse => true, recurselimit => 3,
    }
# This one has to be executable
    file { "/etc/pki/tls/private/.startup":
        owner => root, group => 0, mode => 0700,
    }

    include pki::ca_certs::tls
    class { 'pki::tls::crl':
        http_proxy => $http_proxy,
    }
}
