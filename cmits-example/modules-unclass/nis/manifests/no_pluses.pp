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
# \subsection{Remove NIS lookup directives}
#
# A plus (+) when found alone in any of several system files means to use NIS
# to look up additional entries for that file. We don't use NIS, so this should
# not be the case anywhere.

class nis::no_pluses {
    define no_pluses_in() {
        exec { "no_pluses_in_${name}":
            command => "/bin/echo \
                ---- FOUND A PLUS CHARACTER IN ${name} ----",
            onlyif => [
                "test -f ${name}",
                "grep '^+:*' ${name} >&/dev/null",
            ],
            logoutput => true,
            loglevel => err,
        }
    }

# \index{unixsrg}{Per-user .rhosts and .shosts files}
#
# \implements{unixsrg}{GEN001980} Make sure there are no pluses in system
# authentication data files, causing possibly insecure NIS lookups.
#
# Note that this does not remove pluses from files in home directories as
# required by this PDI, \emph{i.e.}, \verb!.rhosts! and \verb!.shosts!. Note
# further, though, that the \verb!.rhosts! file is supposed to be read by
# \verb!rsh!, \verb!rlogin!, \verb!rexec! and the like, which tools
# \S\ref{class_stig_misc} uninstalls; and the \verb!.shosts! file is supposed
# to be read by \verb!ssh!, but \S\ref{class_ssh::stig} tells the SSH server
# not to pay any attention to it. Note even further that
# \S\ref{define_home::quick} removes \verb!.rhosts! and \verb!.shosts! files
# from home directories, which effectively ensures that they don't contain
# pluses.
    no_pluses_in {
        "/etc/passwd":;
        "/etc/shadow":;
        "/etc/group":;
        "/etc/hosts.equiv":;
        "/etc/shosts.equiv":;
    }
}
