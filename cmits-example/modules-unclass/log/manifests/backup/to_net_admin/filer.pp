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
# This is what the filer policy agent (see~\ref{module_filers}) must do to
# enable log backups to \verb!/net/admin!.

class log::backup::to_net_admin::filer {
    file { "/net/admin/BACKUPS":
        ensure => directory,
        owner => root, group => skadmin, mode => 2770,
    }

# Collect the directories each host has requested; implement those policies on
# the filer policy agent host.
    Log::Backup::To_net_admin::For_host <<| |>>


# Clean out old logs. Keep logs for five years, just in case we have sources
# and methods intelligence (SAMI) on some host. Disks are cheap, noncompliance
# expensive.
    tidy { "/net/admin/BACKUPS":
        recurse => 2,
        matches => "system_logs-*.tar.gz",
        age => "5y",
    }
}
