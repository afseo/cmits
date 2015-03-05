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
# \subsection{Configuring a loghost}
#
# \doneby{admins}{unixsrg}{GEN005460}%
# The ``site-defined procedure'' for setting up and documenting a loghost is
# this:
#
# \begin{enumerate}
# \item Write \verb!include log::loghost! in the node declaration in
# \S\ref{nodes}.
# \item Immediately before this, write a comment containing the tag \verb!\documented{unixsrg}{GEN005460}! and the justification for that host to be a loghost.
# \end{enumerate}
#
# \bydefault{RHEL5}{unixsrg}{GEN005480}%
# RHEL5 does not receive syslog messages by default (see
# \verb!/etc/sysconfig/syslog!).
# \bydefault{RHEL6}{unixsrg}{GEN005480}%
# RHEL6 does not receive syslog messages by default (see
# \verb!/etc/rsyslog.conf!).
# \doneby{admins}{unixsrg}{GEN005480}%
# To prevent inadvertent disclosure of sensitive information, do not configure
# any host to listen for log messages over the network by any other means than
# the above procedure.
#
# Now, this is how a loghost so documented is configured:

class log::rsyslog::loghost($networkname) {
    include log::rsyslog

# Install the SELinux rules that let rsyslogd listen to clients.
    $selmoduledir = "/usr/share/selinux/targeted"
    file { "${selmoduledir}/rsyslog_loghost.pp":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/log/rsyslog/\
rsyslog_loghost.selinux.pp",
    }
    selmodule { "rsyslog_loghost":
       ensure => present,
       syncversion => true,
       notify => Service['rsyslog'],
    }

# The loghost needs a certificate, which will also be distributed to each log
# client.
#
# The loghost needs a copy of the CA certificate(s) which have signed the
# certificates of the log clients.
#
# The locations of these files are written in the \verb!rsyslog.conf! file.

    file { '/etc/rsyslog.d/20loghost.conf':
        owner => root, group => 0, mode => 0640,
        content => template(
            'log/rsyslog/loghost-only/20loghost.conf'),
        notify => Service['rsyslog'],
    }

# Export the to\_loghost resource so that clients can pick it up.
    @@log::rsyslog::to_loghost { "$::fqdn":
        networkname => $networkname,
        ipaddress => $::ipaddress,
    }
}
