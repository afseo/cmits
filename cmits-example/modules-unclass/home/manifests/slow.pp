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
# \subsection{Slow-to-enforce home directory policies}
#
# This defined resource type contains policies that will likely take minutes or
# longer to enforce for a user with many files.

define home::slow() {
    $s = split($name, ':')
    $dir = $s[0]
    $uid = $s[1]
    $gid = $s[2]

# \implements{macosxstig}{GEN001540 M6,GEN001550 M6}%
# \implements{unixsrg}{GEN001540,GEN001550,GEN001560}%
# Control ownership and permissions on files contained in home directories.
#
# It appears that ``contained in'' is intended to mean \emph{anywhere under}
# the home directory. File resources seem to run slowly and take a lot of
# memory in the case of thousands of files; so we use \verb!find!,
# \verb!xargs!, \verb!chown! and \verb!chmod!.  (See
# \ref{class_stig_misc::permissions} for more details on this phenomenon.)
#
# The \verb!-r! switch to xargs is a GNU extension which does not run the given
# command if there are no arguments to run it with. According to the man page,
# ``Normally, the command is run once even if there is no input.''
#
# Under Mac OS X, the xargs command does not accept the \verb!-r! switch, but
# it appears that if there are no arguments to consume, xargs will not run the
# given command. That behavior may be documented by this sentence: ``The xargs
# utility exits immediately... if a command line cannot be assembled...''
    $xargs0 = $osfamily ? {
        darwin  => "xargs -0",
        default => "xargs -0 -r",
    }
    exec { "chown_${uid}_home_files":
        path => ['/bin', '/usr/bin'],
        command => "find '${dir}' -mindepth 1 \\( \
                        \\! -user ${uid} -o \\! -group ${gid} \
                        \\) -print0 | \
                    ${xargs0} chown ${uid}:${gid}",
        onlyif => ["test -d '${dir}'",
               "find '${dir}' -mindepth 1 \
                   \\! -user ${uid} -o \\! -group ${gid} | \
                grep . >&/dev/null"],
    }
    exec { "chmod_${uid}_home_files":
        path => ['/bin', '/usr/bin'],
        command => "find '${dir}' -mindepth 1 \\
                        \\! -type l -perm +026 -print0 | \
                    ${xargs0} chmod g-w,o-rw",
        onlyif => ["test -d '${dir}'",
                "find '${dir}' -mindepth 1 \\
                     \\! -type l -perm +026 | \
                 grep . >&/dev/null"],
    }
# \implements{macosxstig}{GEN001490 M6,GEN001570 M6}%
# \implements{unixsrg}{GEN001490,GEN001570}%
# Remove extended ACLs on home directories, and all files and directories
# therein.
    no_ext_acl { "${dir}": recurse => true }
}
