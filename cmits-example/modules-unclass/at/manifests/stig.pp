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
# \subsection{STIG-required configuration for the at subsystem}

class at::stig {
    case $::osfamily {
        'redhat': { include at::stig::redhat }
        'darwin': { include at::stig::darwin }
        default:  { unimplemented() }
    }
}

# \subsection{Guidance for admins about the at subsystem}
#
# \doneby{admins}{unixsrg}{GEN003360}%
# Never run a group-writable or world-writable program with \verb!at!.
# \doneby{admins}{unixsrg}{GEN003380}%
# Never run a program using \verb!at! which is in or anywhere under a
# world-writable directory (such as \verb!/tmp!).
# \doneby{admins}{macosxstig}{GEN003440 M6}%
# \doneby{admins}{unixsrg}{GEN003440}%
# Don't change the umask in an \verb!at! job.
