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
# \subsubsection{Backing up logs using NFS}
#
# If you had a \verb!/net/admin! directory mounted on each host, to which logs
# could be backed up, this class would do it.
#
# It may not be required to back up logs daily.

class log::backup::to_net_admin {
    file { "/etc/cron.daily/backup_logs":
        owner => root, group => 0, mode => 0700,
        source => "file:///puppet/modules/log/backup/to_net_admin.sh",
    }

# Tell the filer policy agent to make a directory for the logs to land in.
    @@log::backup::to_net_admin::for_host { "$::hostname": }
}
