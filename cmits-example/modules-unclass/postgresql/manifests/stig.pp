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
# \subsection{STIG-required configuration for the PostgreSQL DBMS}

class postgresql::stig($audit_data_changes = false) {
    require augeas
    
# \implements{iacontrol}{ECAR-2,ECRR-1,ECCD-1,ECTP-1,ECTB-1}\implements{databasestig}{DG0029,DG0030,DG0031,DG0032,DG0176}%
# ``Enable auditing on the database.'' Configure the database to log the
# messages required by the STIG, and to send those log messages out via the
# system log. Retention, periodic review, access restriction, and backup, then,
# are handled via the provisions for such requirements against the system log;
# see~\S\ref{module_log}.
#
# Because the logging implementation is not yet complete, these requirements
# are not yet met:
# \begin{itemize}
# \item \unimplemented{databasestig}{DG0083}{Automated notification of
# suspicious activity detected in the audit trail is not implemented.}
# \item \unimplemented{databasestig}{DG0095}{Audit trail data is not reviewed
# daily or more frequently.}
# \item \unimplemented{databasestig}{DG0161}{An automated tool that monitors
# DBMS audit data and immediately reports suspicious activity is not deployed.}
# \end{itemize}
#
# \notapplicable{iacontrol}{ECAR-3}\notapplicable{databasestig}{DG0142}%
# ``Changes to security labels or markings'' are not audited; PostgreSQL ``does
# not support the use of security labels or sensitivity markings,'' so ``this
# check is Not Applicable.'' 
#
# \implements{iacontrol}{ECCD-1,ECAR-2}\implements{databasestig}{DG0031,DG0145}%
# Log all attempts to modify data, if required by ``application design
# requirements;'' if not, only log attempts to modify the structure of the
# database.
#
# For example, the PostgreSQL database used in the SBU system contains user and
# group information used in authorization decisions. That makes everything in
# the database a ``security file,'' most likely, so all changes to data should
# be audited in this case.  But data about flight tests would not be ``security
# files,'' and so a flight test database application may not require auditing
# of all data changes; the server hosting such a database would only log DDL
# statements.
    $log_statement = $audit_data_changes ? {
        true    => 'mod',
        default => 'ddl',
    }

    augeas { "postgresql_logging":
        context => "/files/var/lib/pgsql/data/postgresql.conf",
        changes => [
            "set log_destination syslog",
            "set logging_collector off",
            "set syslog_facility LOCAL0",
            "set syslog_ident postgres",
# \implements{iacontrol}{ECAR-2}\implements{databasestig}{DG0141,DG0145}%
# Log all connection attempts, and every statement that results in a message
# with `error' or greater urgency. This last includes ``failed database object
# attempts,'' ``attempts to access objects that do not exist,'' and ``other
# activities that may produce unexpected failures.''
            "set log_connections on",
            "set log_disconnections on",
            "set log_min_error_statement error",
# \implements{iacontrol}{ECAR-2}\implements{databasestig}{DG0145}%
# Log the name of the acting user for each event. Date and time are taken care
# of by the system log. ``Type of event'' and ``success or failure'' are the
# text of the log message.
#
# \notapplicable{databasestig}{DG0146}%
# Any serious authentication scheme we would implement would be based on
# Kerberos or LDAP; ``blocking or blacklisting a user ID...'' would be logged
# on the authentication server, not by PostgreSQL.
            "set log_line_prefix \"'%q%r %u @ db %d '\"",
            "set log_statement '${log_statement}'",
        ],
        require => Exec['postgresql_initdb'],
        notify => Service['postgresql'],
    }

# \implements{iacontrol}{ECLO-1}\implements{databasestig}{DG0134}%
# Limit concurrent connections to the database. The vendor recommends 100
# concurrent connections as a starting limit.
    augeas { "postgresql_connections":
        context => "/files/var/lib/pgsql/data/postgresql.conf",
        changes => [
            "set max_connections 100",
        ],
        require => Package['postgresql-server'],
    }

# \notapplicable{iacontrol}{IAIA-1}\notapplicable{databasestig}{DG0131}%
# The \verb!postgres! database account is the only default account for
# PostgreSQL. Upon investigation, PostgreSQL as included in RHEL ``does not
# support changes to'' this ``default account name'' so ``this check is Not
# Applicable only for those accounts that cannot be altered.''
#
# In terms of real security, the \verb!postgres! database user can only be used
# by the local \verb!postgres! operating system user, which is not allowed to
# log in, so in order to do anything as the \verb!postgres! database user, an
# attacker would first have to become root; in any such scenario, all bets are
# off anyway. See on \databasestig{DG0041}.
#
# Because PostgreSQL and RHEL are open-source software, changing the name of
# the \verb!postgres! user is possible, but it would require making a custom
# PostgreSQL package, which would unacceptably slow down and complicate
# security patch testing and installation. It would be entirely true to say
# that such a thing is ``unsupported.''
#
# \implements{iacontrol}{ECLP-1,ECPA-1}\implements{databasestig}{DG0080,DG0086,DG0116,DG0118}%
# Provide for ``monthly... review of privilege assignments,'' including DBA
# roles, within the PostgreSQL database by causing a report of roles and
# privileges to be sent to the administrators for review.

    file { "/etc/cron.monthly/postgresql-privileges-report":
        owner => root, group => 0, mode => 0700,
        source => "puppet:///modules/postgresql/privs-report.sh",
    }
}
