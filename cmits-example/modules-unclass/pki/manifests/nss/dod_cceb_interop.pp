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
# \subsection{Install DoD CCEB interoperability root cert(s)}
#
# This defined resource type will install DoD CCEB interoperability root CA
# certificates into the named database. These offer a trust path to
# some certificates issued outside the DoD. See
# \url{http://iase.disa.mil/pki-pke/interoperability/} for more details, and
# for rules under which you must operate when trusting this CA from a DoD
# server.

define pki::nss::dod_cceb_interop($pwfile='', $sqlite=true) {
    nss_cert { "${name}:DoD-CCEB-Interop-Root-CA1":
        source => "puppet:///modules/pki/all-ca-certs/",
        trustargs => 'CT,C,C',
        pwfile => $pwfile,
        require => Pki::Nss::Db[$name],
        sqlite => $sqlite,
    }
}
