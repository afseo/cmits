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
# \subsubsection{Make Subversion trust the DoD PKI}

class subversion::pki::trust_cas {
# Make sure the CA certs are somewhere we expect.
    include pki::ca_certs::tls

    require subversion::servers_config
    augeas { 'subversion_root_ca':
        context => '/files/etc/subversion/servers/global',
        changes => [
# If you add more \verb!ssl-authority-files!, they should be delimited by
# semicolons, with no spaces in between them.
            "set ssl-authority-files \
/etc/pki/tls/cacerts/DoD-Root2-Root.crt",
        ],
    }
}
