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
# \subsubsection{Maintain CRLs for TLS CA certificates}
#
# \implements{apachestig}{WG145 A22} Keep certificate revocation lists (CRLs) up
# to date.

class pki::tls::crl($http_proxy='') {

# The CRL updating script needs this.
    package { "python-ldap": ensure => present }

    file { "/etc/pki/tls/crls":
        ensure => directory,
        owner => root, group => 0, mode => 0644,
        recurse => true, recurselimit => 1,
    }

    file { "/usr/sbin/refresh_crls.py":
        owner => root, group => 0, mode => 0755,
        source => "puppet:///modules/pki/\
get_crl/refresh_crls.py",
    }

    file { "/etc/cron.daily/refresh_crls":
        owner => root, group => 0, mode => 0700,
        content => "#!/bin/sh\n\
export http_proxy=${http_proxy}\n\
/usr/sbin/refresh_crls.py \
  /etc/pki/tls/cacerts \
  /etc/pki/tls/crls\n",
    }
}
