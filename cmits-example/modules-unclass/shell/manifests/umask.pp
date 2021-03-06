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
# \subsection{Set default umask}
#
# \implements{unixsrg}{GEN002560} Set the system default umask to \verb!077!,
# so that by default files are only accessible by the user who created them.
class shell::umask {

    define make_umasks_077_in() {
        exec { "umask_077_in_${name}":
            command => "sed -i -e \
                's/\\(^[[:space:]]*umask\\>\\).*/\\1 077/' \
                ${name}",
            onlyif => "grep '^[[:space:]]*umask' ${name} | \
                       grep -v 'umask 077\$'",
        }
    }
    make_umasks_077_in {
        '/etc/profile':;
        '/etc/bashrc':;
        '/etc/csh.cshrc':;
    }
}
