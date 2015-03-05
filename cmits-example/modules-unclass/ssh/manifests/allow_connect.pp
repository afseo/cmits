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
# \subsection{Limit SSH connections by host IP}
#
# \implements{unixsrg}{GEN005540} Configure the SSH daemon for IP filtering
# using TCP wrappers.
#
# Example:
# \begin{verbatim}
#     ssh::allow_connect { "127.0.0.1, 192.168.0.": }
# \end{verbatim}
#
# This is just a wrapper for \verb!tcp_wrappers::allow!, \emph{q.v.}
# (\S\ref{define_tcp_wrappers::allow})

define ssh::allow_connect {
    tcp_wrappers::allow { "sshd":
        from => $name,
    }
}
