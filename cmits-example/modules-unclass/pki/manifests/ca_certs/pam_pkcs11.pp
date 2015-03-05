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
# \subsubsection{/etc/pki/pam\_pkcs11}
#
# Install selected CA certs into an NSS database just for pam\_pkcs11. This is
# because we only want to trust the DoD identity CAs for local CAC logins, not
# (for example) the ECAs.


class pki::ca_certs::pam_pkcs11 {
    pki::nss::db { "/etc/pki/pam_pkcs11":
        owner => root, group => 0, mode => 0644,
    }
    Nss_cert {
        dbdir => "/etc/pki/pam_pkcs11",
        source => "puppet:///modules/pki/all-ca-certs/",
        require => Pki::Nss::Db["/etc/pki/pam_pkcs11"],
    }
    nss_cert {
        "DoD-Root2-CA19":;
        "DoD-Root2-CA20":;
        "DoD-Root2-CA21":;
        "DoD-Root2-CA22":;
        "DoD-Root2-CA23":;
        "DoD-Root2-CA24":;
        "DoD-Root2-CA25":;
        "DoD-Root2-CA26":;
        "DoD-Root2-CA27":;
        "DoD-Root2-CA28":;
        "DoD-Root2-CA29":;
        "DoD-Root2-CA30":;
        "DoD-Root2-CA31":;
        "DoD-Root2-CA32":;
        "DoD-Root2-Root":;
    }
    nss_cert {
        "DoD-Root2-CA11": ensure => absent;
        "DoD-Root2-CA12": ensure => absent;
        "DoD-Root2-CA13": ensure => absent;
        "DoD-Root2-CA14": ensure => absent;
        "DoD-Root2-CA15": ensure => absent;
        "DoD-Root2-CA16": ensure => absent;
        "DoD-Root2-CA17": ensure => absent;
        "DoD-Root2-CA18": ensure => absent;
    }
}

