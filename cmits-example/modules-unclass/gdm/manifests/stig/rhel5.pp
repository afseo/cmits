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

class gdm::stig::rhel5 {
# Make sure the file we're about to edit exists: if we have no custom options
# set yet, it won't.
    file { "/etc/gdm/custom.conf":
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }
# \implements{rhel5stig}{GEN000000-LNX00360}%
# \implements{rhel5stig}{GEN000000-LNX00380} Set the right X server options
# (\verb!-s! [screensaver timeout], \verb!-audit! [audit level], and
# \verb!-auth! [authorization record file], which ``gdm always automatically
# uses''), and don't set the wrong ones (\verb!-ac! [disable host-based access
# control], \verb!-core! [dump core on fatal errors], and \verb!-nolock!
# [unknown, not in man page]). (The \verb!-br! option merely makes the screen
# black by default when the server starts up, instead of the gray weave
# pattern.)
    require augeas
    augeas { "gdm_servers_switches":
        require => File["/etc/gdm/custom.conf"],
        context => "/files/etc/gdm/custom.conf/server-Standard",
# Copied from Red Hat 5 STIG fix text.
        changes => [
            "set command '/usr/bin/Xorg -br -audit 4 -s 15'",
            "set name 'Standard server'",
            "set chooser false",
            "set handled true",
            "set flexible true",
            "set priority 0",
        ],
    }
}
