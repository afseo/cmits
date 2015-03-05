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
# \subsection{``Unowned'' files}
#
# \implements{unixsrg}{GEN001160,GEN001170}%
# \implements{macosxstig}{GEN001160 M6,GEN001170 M6}%
# Check for files and directories with unknown owners.
#
# We assume here that any NFS filesystem which may be mounted will be under
# \verb!/net!. If that assumption does not hold, we'll end up searching across
# an NFS filesystem. That could take a while and spit out a bunch of errors.

class stig_misc::find_unowned {
    exec { 'files_with_unknown_owner_or_group':
        path => ['/bin', '/usr/bin'],
        command => "find / -path /net -prune -o \
                -nouser -ls -o \
                -nogroup -ls",
        logoutput => true,
        loglevel => err,
    }
}
