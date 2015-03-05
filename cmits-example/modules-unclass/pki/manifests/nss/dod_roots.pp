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
# \subsection{Install DoD root cert(s)}
#
# This defined resource type will install DoD root CA certificates (no
# intermediate CAs, no ECAs) into the named database.

define pki::nss::dod_roots($pwfile='', $sqlite=true) {
    nss_cert { "${name}:DoD-Root2-Root":
        source => "puppet:///modules/pki/all-ca-certs/",
        trustargs => 'CT,C,C',
        pwfile => $pwfile,
        require => Pki::Nss::Db[$name],
        sqlite => $sqlite,
    }
}
