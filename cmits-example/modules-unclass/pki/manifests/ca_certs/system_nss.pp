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
# \subsubsection{Systemwide NSS (/etc/pki/nssdb)}
#
# Install CA certs into the systemwide NSS database.

class pki::ca_certs::system_nss {
    $db = "/etc/pki/nssdb"
    pki::nss::db { $db:
        owner => root, group => 0, mode => 0644,
    }
    pki::nss::dod_roots { $db: }
    pki::nss::dod_cas { $db: }
    pki::nss::dod_email_cas { $db: }
    pki::nss::eca_roots { $db: }
    pki::nss::eca_cas { $db: }
}
