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
# \subsubsection{Add PostgreSQL ident map entries}
#
# This define is used by the \verb!postgresql::identmap! define, \emph{q.v.}
#
# Since there's likely more than one database user in question, our strategy is
# to define a resource type pertaining to one database user, and pass an array
# of database users in as the name parameter in order to construct an array of
# these defined resources. Search for ``puppet for loop'' to find out more on
# this strategy.

define postgresql::identmap::entry($os_user, $database) {
    $db_user = $name

    include postgresql

# Yes, this is a long name, but it must be unique across the entire manifest.
    augeas { "pg_ident_${os_user}_as_${db_user}_into_${database}":
        context => '/files/var/lib/pgsql/data/pg_ident.conf',
        changes => [
            "set 999/map     '${database}'",
            "set 999/os_user '${os_user}'",
            "set 999/db_user '${db_user}'",
        ],
        onlyif => "match *[map='${database}' and \
                           os_user='${os_user}' and \
                           db_user='${db_user}'] \
                           size < 1",
        require => Exec['postgresql_initdb'],
        notify => Service['postgresql'],
    }
}
