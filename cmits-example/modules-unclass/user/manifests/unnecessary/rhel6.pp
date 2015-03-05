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
# \subsubsection{Under RHEL6}
#
# On a freshly installed RHEL6 system, there exist files owned by the following users:
# % Oho, so smart, to columnize, but hard to edit...
# \begin{verbatim}
# abrt         lp          rpc
# apache       ntp         rpcuser
# avahi        postfix     tss
# daemon       pulse       vcsa
# gdm          puppet
# haldaemon    root
# \end{verbatim}
#
# The following users, then, do not own any files:
# \begin{verbatim}
# bin         uucp        rtkit
# adm         games       saslauth
# sync        gopher      sshd
# shutdown    ftp         tcpdump
# halt        nobody      nfsnobody
# mail        dbus
# \end{verbatim}
#
# The system users not owning any files, listed above, are mostly associated
# with system processes;
# \bydefault{RHEL6}{unixsrg}{GEN000280}%
# they are disabled from logging in by default.
#
# The full list of possible system users under RHEL6 can be found in the
# Deployment Guide \cite{rhel6-deployment}, \S 3.3. A user from that list is
# added when the package requiring the user is installed, so
# \bydefault{RHEL6}{unixsrg}{GEN000290}%
# application accounts do not exist for applications not installed on the
# system. Policy regarding user accounts for people, including ensuring that
# people who aren't going to use a host are not added as users of that host, is
# dealt with in other subsections of \S\ref{module_user}.

class user::unnecessary::rhel6 {
    
# \implements{rhel5stig}{GEN000000-LNX00320}%
# Remove the \verb!shutdown!, \verb!halt!  and \verb!reboot! user accounts. The
# requirement says ``special privilege accounts'' must be removed, but only
# mentions these three.
    user { ["shutdown", "halt", "reboot"]:
        ensure => absent,
    }
#
# \implements{unixsrg}{GEN000290}%
# Some system users are installed by the \verb!setup! package, but not
# subsequently used. Remove them.
#
# Not least to make pwck happy: their home directories seem not to usually
# exist. 
    user { ["adm", "uucp", "gopher"]:
        ensure => absent,
    }
# This user is listed as belonging to the \verb!cyrus-imapd! package; we don't
# run IMAP servers.
    user { "saslauth":
        ensure => absent,
    }

    if($gdm_installed == 'false') {
        user { "gdm":
            ensure => absent,
        }
    }
}
