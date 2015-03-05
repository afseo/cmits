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
# \subsection{Secure run control scripts}

class stig_misc::run_control_scripts {
# \implements{macosxstig}{GEN001580 M6}%
# \implements{unixsrg}{GEN001580}%
# Restrict permissions on the run control scripts.
#
# \implements{rhel5stig}{GEN001660,GEN001680}%
# Restrict ownership on ``system start-up files.''
#
# What constitutes a \emph{run control script} is defined by implication in the
# check content of various STIGs. Confusingly enough, the RHEL 5 STIG check
# content implies that for that STIG, ``run control scripts'' and ``system
# start-up files'' are the same files.
    $run_control_scripts = $::osfamily ? {
        'darwin' => [ '/System/Library/LaunchDaemons',
                     '/System/Library/LaunchAgents',
                     '/Library/LaunchDaemons',
                     '/Library/LaunchAgents' ],
        'redhat' => [ '/etc/rc.d' ],
        default  => unimplemented,
    }
    file { $run_control_scripts:
        owner => root,
# RHEL default group owner is root for all these files. 
        group => 0,
        mode => go-w,
        recurse => true,
        recurselimit => 3,
    }
# \implements{macosxstig}{GEN001590 M6}%
# \implements{unixsrg}{GEN001590}%
# Remove extended ACLs on run control scripts.
    no_ext_acl { $run_control_scripts: recurse => true }
}
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN001600}%
# All run control scripts that come with RHEL contain only absolute paths as
# entries in their \verb!PATH!  variable settings.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN001605}%
# No run control scripts that come with RHEL set the \verb!LD_LIBRARY_PATH!,
# and it is empty by default. So, trivially, for all run control scripts, the
# library search paths contain only absolute paths, as required.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN001610}%
# No run control scripts that come with RHEL set the \verb!LD_PRELOAD!, and it
# is empty by default. So, trivially, for all run control scripts, the list of
# preloaded libraries contains only absolute paths.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN001640}%
# All executables that come with RHEL are not world-writable, so it is
# impossible for a stock startup script to execute a world-writable program or
# script.
#
#
# \subsection{Admin guidance about run control scripts}
#
# \doneby{admins}{unixsrg}{GEN001600}%
# Do not deploy any run control script that contains a relative path or empty
# entry in a PATH variable setting. You should never need to change the
# \verb!PATH! in a run control script anyway.
# \doneby{admins}{unixsrg}{GEN001605,GEN001610}%
# Similarly, never set \verb!LD_PRELOAD! and never put a relative or empty
# entry into the \verb!LD_LIBRARY_PATH! used in a run control script.
# \doneby{admins}{unixsrg}{GEN001640}%
# Never deploy a run control script that executes a world-writable program or
# script. Any run control script that runs a program or script stored on an NFS
# share should be documented in \S\ref{DocumentedWithIAO}.
#
# As noted above, RHEL does not come with any world-writable local programs or
# scripts. The \verb!aide! subsystem will detect any adverse permission
# changes; see \S\ref{class_aide}. Do not install any world-writable programs
# or scripts.
