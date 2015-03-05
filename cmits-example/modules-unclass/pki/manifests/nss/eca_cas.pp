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
# \subsection{Install ECA CA cert(s)}
#
# This defined resource type will install CA certificates for External
# Certification Authorities (ECAs) into the named NSS database.

define pki::nss::eca_cas($pwfile='', $sqlite=true) {
    Nss_cert {
        source => "puppet:///modules/pki/all-ca-certs/",
        pwfile => $pwfile,
        sqlite => $sqlite,
        require => [
            Pki::Nss::Db[$name],
            Nss_cert["${name}:ECA-Root2"],
        ],
    }
    nss_cert {
#
# CA certs issued by the ECA Root CA: None seem to exist any more.
#
        "${name}:ECA-ORC2":
            ensure => absent;
        "${name}:ECA-Identitrust1":
            ensure => absent;
#
# CA certs issued by ECA Root CA 2:
#
        "${name}:ECA-Verisign-G2":
            ensure => absent;
        "${name}:ECA-IdenTrust2":
            ensure => absent;
        "${name}:ECA-ORC-HW3":
            ensure => absent;
        "${name}:ECA-ORC-SW3":
            ensure => absent;
        "${name}:ECA-ORC-HW4":;
        "${name}:ECA-ORC-SW4":;
        "${name}:ECA-IdenTrust3":;
        "${name}:ECA-IdenTrust4":;
        "${name}:ECA-Verisign-G3":;
    }
}
