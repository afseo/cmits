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
# \subsection{Install DoD email CA certs}
#
# This defined resource type will install DoD email CA certificates (not
# identity CAs, not ECAs) into the named NSS database.
define pki::nss::dod_email_cas($pwfile='', $sqlite=true) {
    Nss_cert {
        source => "puppet:///modules/pki/all-ca-certs/",
        pwfile => $pwfile,
        sqlite => $sqlite,
        require => [
            Pki::Nss::Db[$name],
            Nss_cert["${name}:DoD-Root2-Root"],
        ],
    }

    nss_cert {
        "${name}:DoD-email-Root2-CA21":;
        "${name}:DoD-email-Root2-CA22":;
        "${name}:DoD-email-Root2-CA23":;
        "${name}:DoD-email-Root2-CA24":;
        "${name}:DoD-email-Root2-CA25":;
        "${name}:DoD-email-Root2-CA26":;
        "${name}:DoD-email-Root2-CA27":;
        "${name}:DoD-email-Root2-CA28":;
        "${name}:DoD-email-Root2-CA29":;
        "${name}:DoD-email-Root2-CA30":;
    }

# Remove expired CA certs.
    nss_cert {
        "${name}:DoD-email-Root2-CA11": ensure => absent;
        "${name}:DoD-email-Root2-CA12": ensure => absent;
        "${name}:DoD-email-Root2-CA13": ensure => absent;
        "${name}:DoD-email-Root2-CA14": ensure => absent;
        "${name}:DoD-email-Root2-CA15": ensure => absent;
        "${name}:DoD-email-Root2-CA16": ensure => absent;
        "${name}:DoD-email-Root2-CA17": ensure => absent;
        "${name}:DoD-email-Root2-CA18": ensure => absent;
        "${name}:DoD-email-Root2-CA19": ensure => absent;   
        "${name}:DoD-email-Root2-CA20": ensure => absent;
	}
}
