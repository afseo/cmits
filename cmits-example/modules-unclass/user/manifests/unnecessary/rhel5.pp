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
# \subsubsection{Under RHEL5}
#
# Here we have guidance from the Red Hat 5 STIG---specific, if unclear.

class user::unnecessary::rhel5 {
# \implements{rhel5stig}{GEN000000-LNX00320} Remove the \verb!shutdown!,
# \verb!halt!  and \verb!reboot! users. The requirement says to remove
# ``special privilege accounts'' but only mentions these three.
    user { ["shutdown", "halt", "reboot"]:
        ensure => absent,
    }
# \implements{rhel5stig}{GEN000290-1,GEN000290-2,GEN000290-3,GEN000290-4}%
# Remove the \verb!games!, \verb!news!, \verb!gopher! and \verb!ftp! accounts.
#
# (The \verb!ftp! account is taken care of in \S\ref{class_ftp::no}.)
    user { ['games', 'news', 'gopher']:
        ensure => absent,
    }

}
