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
# \subsection{Manual page file permissions}

class stig_misc::man_page_files {
# \implements{unixsrg}{GEN001280}%
# \implements{macosxstig}{GEN001280 M6}%
# Lock down permissions for manual page files.
#
# (There are so many of these that specifying policy for them using the file
# resource type ran into speed and memory problems.)

    $man_page_dirs = ['/usr/share/man']

# \index{g}{portability}%
# We use the \verb!-perm +! syntax for \verb!find! even though it is deprecated
# by GNU find, because Mac OS X's \verb!find! doesn't understand the
# recommended \verb!-perm /! syntax.

    exec { "chmod_man_pages":
        path => ['/bin', '/usr/bin'],
        command => "chmod -c -R go-w ${man_page_dirs}",
        onlyif  => "find ${man_page_dirs} \
                \\! -type l -perm +022 | \
            grep . >&/dev/null",
        logoutput => true,
    }
    exec { "chown_man_pages":
        path => ['/bin', '/usr/bin'],
        command => "chown -c -R root:0 ${man_page_dirs}",
        onlyif  => "find ${man_page_dirs} \
                \\! -user root -o \\! -group 0 | \
            grep . >&/dev/null",
        logoutput => true,
    }
# \implements{unixsrg}{GEN001290}%
# \implements{macosxstig}{GEN001290 M6}%
# Remove any extended ACLs from manual page files.
    no_ext_acl { "/usr/share/man": recurse => true }
}
