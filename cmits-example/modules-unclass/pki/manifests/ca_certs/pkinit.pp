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
# \subsubsection{HPC Kerberos {\tt pkinit}}
#
# Install CA certs into the /etc/pki directory, where they will be used by
# the {\tt pkinit} utility from the HPCMP Kerberos distribution.
#
# {\tt pkinit} wants the root certificates and the CA certificates in different
# directories, so we put the root certificates in a \verb!root! subdirectory
# beside the CA certificates, in \verb!/etc/pki/dod!.

class pki::ca_certs::pkinit {
    include pki
    file { "/etc/pki/pkinit":
        ensure => directory,
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/pki/pkinit",
        recurse => true,
# We are copying files in a subdirectory---increase recurselimit.
        recurselimit => 2,
        ignore => ".svn",
        purge => true,
    }
}
