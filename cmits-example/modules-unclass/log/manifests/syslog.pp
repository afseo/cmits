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
# \subsection{Logging via syslogd}
# 
# No provisions for remote logging are made here as they are with rsyslog.

class log::syslog {
# \implements{macosxstig}{GEN005400 M6,GEN005420 M6}%
# Control ownership and permissions of the \verb!syslog.conf! file.
    file { '/etc/syslog.conf':
        owner => root, group => 0,
    }
# \implements{macosxstig}{GEN005395 M6}%
# Remove extended ACLs from the \verb!syslog.conf! file.
    no_ext_acl { '/etc/syslog.conf': }
}

