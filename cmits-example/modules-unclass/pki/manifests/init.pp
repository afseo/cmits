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
# \section{PKI (Public Key Infrastructure)}
# \label{pki}
#
# Configure PKI-related parts of the system. These have to do with
# certification authority (CA) certificates, certificate revocation lists
# (CRLs) and the like.

class pki {
    file { '/etc/pki':
        ensure => directory,
        owner => root, group => 0, mode => 0644,
    }
}
