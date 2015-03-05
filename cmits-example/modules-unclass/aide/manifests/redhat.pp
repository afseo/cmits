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
# \subsection{AIDE configuration for Red Hat}

class aide::redhat {
    package { "aide":
        ensure => present,
    }

# \implements{unixsrg}{GEN000140,GEN006570,GEN006571,GEN006575}%
# Install the
# prescribed configuration for AIDE, causing it to baseline device files,
# extended access control lists (ACLs), and extended attributes, using FIPS
# 140-2 approved cryptographic hashing algorithms.
#
# \implements{iacontrol}{DCSL-1}\implements{databasestig}{DG0050}%
# Configure AIDE to create and monitor a baseline of database ``software
# libraries, related applications and configuration files.''
    file { "/etc/aide.conf":
        owner => root, group => 0, mode => 0600,
        source => "puppet:///modules/aide/aide.conf",
    }

# Warn if the aide binary changes.
    file { "/usr/sbin/aide":
        audit => all,
    }

# \implements{unixsrg}{GEN000220,GEN002400,GEN002460}%
# Check for unauthorized changes to system files, including setuid files and
# setgid files, every week.
    cron { aide:
        command => "/usr/sbin/aide --check",
        user => root,
        hour => 2,
        minute => 2,
        weekday => 0,
    }

# Make sure aide's logs are rotated.

    augeas { "aide_weekly":
        context => "/files/etc/logrotate.d/aide/rule",
        changes => "set schedule weekly",
    }

# Since aide is run by logrotate, make sure logrotate is working.
#
# \implements{unixsrg}{GEN003100,GEN003120,GEN003140}%
# Use mode \verb!0700! for the daily log rotation script, as required.
    file { "/etc/cron.daily/logrotate":
        owner => root, group => 0, mode => 0700,
        source => "puppet:///modules/aide/logrotate",
    }

# Install the baseline backup script for use by administrators. See
# \S\ref{backup_baseline_usage}.
    file { "/usr/sbin/backup_baseline.sh":
        owner => root, group => 0, mode => 0755,
        source => "puppet:///modules/aide/backup_baseline.sh",
    }
}
