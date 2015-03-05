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
# \subsection{Configuring remote logging clients}
#
# (This excludes configuration of exactly which log server to use; see
# \S\ref{define_log::rsyslog::to_loghost}.)

class log::rsyslog::client($networkname) {
    include log::rsyslog
# Install the SELinux rules that let rsyslogd talk to the loghost.
    $selmoduledir = "/usr/share/selinux/targeted"
    file { "${selmoduledir}/rsyslog_client.pp":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/log/rsyslog/\
rsyslog_client.selinux.pp",
    }
    selmodule { "rsyslog_client":
       # autorequires above file
       ensure => present,
       syncversion => true,
       notify => Service['rsyslog'],
    }

# Collect the to\_loghost resource exported by the loghost.
    Log::Rsyslog::To_loghost <<| 
        networkname == $networkname
    |>>

# The client needs a certificate that the server will recognize in order to connect.
#
# The client needs the CA certificate(s) installed so it can authenticate the
# server.
#
# Configuration of the rsyslogd (\verb!/etc/rsyslog.conf!) is set in
# \S\ref{define_log::rsyslog::to_loghost} because it depends on the loghost's address.

}
