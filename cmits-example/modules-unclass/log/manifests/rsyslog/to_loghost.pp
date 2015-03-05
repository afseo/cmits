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
# \subsection{Sending log messages to a loghost}
#
# \implements{unixsrg}{GEN005450} ``[U]se a remote syslog server (loghost),''
# so that the remotely collected system log data ``can be used as an
# authoritative log source in the event a system is compromised and its local
# logs are suspect,'' and so that it's easier to check logs every day and set
# up automated alerts.
#
# Call this define with the name of the loghost. It must match the common name
# in the loghost's certificate.
#
# The way this happens is that the loghost exports one of these (the Puppet
# term here is ``exported resources''), and the clients collect it. So the name
# parameter is given by the loghost, but the contents of the define happen on
# the clients.
#
# (See~\S\ref{manifests/templates.pp} and~\S\ref{manifests/nodes.pp}
# for places where this defined resource type is used.)

define log::rsyslog::to_loghost($networkname, $ipaddress) {
    $loghost = $name
    file { '/var/spool/rsyslog':
        ensure => directory,
        owner => root, group => 0, mode => 0700,
    }
    file { "/etc/rsyslog.d/80send-to-loghost.conf":
        owner => root, group => 0, mode => 0640,
        content => template(
            'log/rsyslog/client-only/80send-to-loghost.conf'),
        notify => Service['rsyslog'],
        require => File['/var/spool/rsyslog'],
    }
    augeas { "add loghost to /etc/hosts":
        context => "/files/etc/hosts",
        changes => [
            "set 999/ipaddr '$ipaddress'",
            "set 999/canonical '$loghost'",
            "set 999/alias[999] loghost",
        ],
        onlyif => "match *[canonical='$loghost'] size == 0",
    }
}
