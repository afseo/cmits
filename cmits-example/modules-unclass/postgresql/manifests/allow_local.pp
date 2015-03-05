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
# \subsection{Allow a local PostgreSQL user}
#
# This defined resource type is a shortcut to let a given user local to
# the DBMS server connect to a given database with the same username between
# the OS and database. Real people should connect this way.

define postgresql::allow_local($database) {
    require postgresql::initialize
    include postgresql
# This depends on the postgresql class, but since it will most likely
# be used from inside that class, notating such a dependency would
# result in a dependency cycle.
    augeas { "pg_hba_${name}_into_${database}":
        context => '/files/var/lib/pgsql/data/pg_hba.conf',
        changes => [
            'set 999/type      local',
            "set 999/database  '${database}'",
            "set 999/user      '${name}'",
            'set 999/method    ident',
        ],
        onlyif => "match *[user='${name}'] size < 1",
        require => Class['postgresql::initialize'],
        notify => Service['postgresql'],
    }
}
