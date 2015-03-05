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
# \subsection{Disable GSSAPI authentication}
#
# Where GSSAPI authentication is not needed, disable it.

class ssh::no_gssapi {
    include ssh
    augeas { "sshd_no_gssapi":
        context => "/files${ssh::server_config}",
        changes => [
# \implements{unixsrg}{GEN005524}%
# Disable GSSAPI authentication in the SSH server ``unless needed.'' In some
# cases we do not need it.
            "set GSSAPIAuthentication no",
        ],
    }

# The \verb!/etc/ssh/ssh_config! file is parsed by a non-stock lens.
    require augeas

    augeas { "ssh_client_no_gssapi":
        context => "/files${ssh::client_config}/Host[.='*']",
        changes => [
# \implements{unixsrg}{GEN005525}%
# Disable GSSAPI authentication in the SSH client ``unless needed.'' In some
# cases we do not need it.
            "set GSSAPIAuthentication no",
        ],
    }
}

