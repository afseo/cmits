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
# \subsection{Library files}

class stig_misc::library_files {
# \implements{macosxstig}{GEN001300 M6}%
# Lock down permissions for ``library files.''
    $library_dirs = $::osfamily ? {
        'darwin' => [ '/System/Library/Frameworks',
                     '/Library/Frameworks',
                     '/usr/lib',
                     '/usr/local/lib' ],
        'redhat' => [ '/lib', '/lib64',
                     '/usr/lib', '/usr/lib64',
                     '/usr/local/lib', '/usr/local/lib64' ],
        default  => [ '/usr/lib', '/usr/local/lib' ],
    }
    file { $library_dirs:
        mode => go-w,
    }

# \implements{macosxstig}{GEN001310 M6}%
# \implements{unixsrg}{GEN001310}%
# Remove any extended ACLs from library files.
    no_ext_acl { $library_dirs: recurse => true }
}
