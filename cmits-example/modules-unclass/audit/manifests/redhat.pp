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
class audit::redhat {

# \implements{unixsrg}{GEN002660}%
# Install the auditing software.
    package { "audit":
        ensure => present,
    }
# \implements{unixsrg}{GEN002860}%
# Rotate audit logs daily.
#
# The example provided with auditd uses cron, not
# logrotate, and we follow suit.
#
# \implements{unixsrg}{GEN003100,GEN003120,GEN003140}%
# Use mode \verb!0700! for the auditd daily cron script, as required.
    file { "/etc/cron.daily/auditd.cron":
        owner => root, group => 0, mode => 0700,
        source => "puppet:///modules/audit/auditd.cron",
    }
# We need a non-stock Augeas lens to edit the auditd.conf.
    require augeas

    augeas { "auditd_conf":
        context => "/files/etc/audit/auditd.conf",
        changes => [
# \implements{unixsrg}{GEN002860}%
# Rotate audit log files based on time, not their size.
            "set max_log_file_action ignore",
# Keep a ridiculous number of logs. (Most of our machines have a lot of local
# free space.)
            "set num_logs 30",
# \implements{iacontrol}{ECRR-1}%
# ``[E]nsure that audit logs that have reached maximum length are not
# overwritten,'' by suspending the system if space for audit logs runs out or
# disk errors prevent the writing of audit logs.
            "set admin_space_left 50",
            "set admin_space_left_action SUSPEND",
            "set disk_full_action SUSPEND",
            "set disk_error_action SUSPEND",
# \implements{unixsrg}{GEN002719,GEN002730}%
# \implements{rhel6stig}{RHEL-06-000005}%
# Send an email to the administrator when disk space reserved for audit logs
# runs low. Mail for root is set up to go to the right places by
# \S\ref{define_mail::root}.
            "set space_left 300",
            "set space_left_action email",
            "set action_mail_acct root",
        ],
        notify => Service["auditd"],
    }

# \implements{unixsrg}{GEN002720,GEN002740,GEN002750,GEN002751,GEN002752,GEN002753,GEN002760,GEN002800,GEN002820,GEN002825}%
# Configure the auditing subsystem according to the requirements of the UNIX
# SRG.
    file { "/etc/audit/audit.rules":
        owner => root, group => 0, mode => 0640,
        source => "puppet:///modules/audit/\
${architecture}-stig.rules",
        notify => Service["auditd"],
    }

# Reload auditd, don't restart it.
    service { "auditd":
        restart => "/sbin/service auditd reload",
    }
}
