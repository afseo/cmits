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
# \section{PostgreSQL database server}
#
# Being a client-server Database Management System (DBMS), PostgreSQL is
# subject to the General Database STIG \cite{database-stig}. As with any STIG,
# some requirements can be automatically enforced by this policy and some are
# up to database administrators (DBAs), system administrators (SAs) and users
# to fulfill on an ongoing basis.
#
# This class has to do with PostgreSQL servers. Policy-based PostgreSQL client
# configuration will be under postgresql::client; this is not yet written.

class postgresql($audit_data_changes = false) {

    require postgresql::initialize
    service { "postgresql":
        enable => true,
        ensure => running,
        require => Class['postgresql::initialize'],
# Don't interrupt service when settings change. If postgresql.conf changes and
# the server needs to be restarted, not reloaded, that should happen during
# some planned downtime or something.
        restart => "/sbin/service postgresql reload",
    }

# Get rid of the wide-open initially installed connection permissions (and any
# wide-open permissions that follow).
    augeas { 'remove_hba_wideopen_defaults':
        context => '/files/var/lib/pgsql/data/pg_hba.conf',
        changes => [
            'rm *[database="all"]',
        ],
        require => Exec['postgresql_initdb'],
        notify => Service['postgresql'],
    }
# But make sure postgres can still connect to the postgres database.
    postgresql::allow_local { 'postgres':
        database => 'postgres'
    }

# Now apply STIG-based policies regarding the server configuration, and add
# users for Puppet and for admins.
    class { 'postgresql::stig':
        audit_data_changes => $audit_data_changes,
    }
    include postgresql::puppet_dba
    include postgresql::roles
}
