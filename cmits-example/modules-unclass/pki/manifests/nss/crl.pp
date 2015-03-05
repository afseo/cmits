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
# \subsubsection{Maintain CRLs for NSS database}
#
# \implements{apachestig}{WG145 A22} Keep certificate revocation lists (CRLs) up
# to date.

define pki::nss::crl($dbdir, $pwfile, $http_proxy='', $sqlite=true) {
    file { "/usr/sbin/refresh_crls_nss.py":
        owner => root, group => 0, mode => 0755,
        source => "puppet:///modules/pki/\
get_crl/refresh_crls_nss.py",
    }

    $berkeley_switch = $sqlite ? {
        true  => '',
        false => '-B',
    }
    file { "/etc/cron.daily/refresh_nss_crls_${name}":
        owner => root, group => 0, mode => 0700,
        content => "#!/bin/sh
export http_proxy=${http_proxy}

/usr/sbin/refresh_crls_nss.py \
        ${berkeley_switch} ${dbdir} ${pwfile}
",
    }
}
