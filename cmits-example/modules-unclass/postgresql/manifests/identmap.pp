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
# \subsection{Allow an OS user into PostgreSQL as any of several users}
#
# This defined resource type is a shortcut to let a given OS user local to
# the DBMS server connect to a given database with any of several databse
# usernames, in order to make use of different sets of privileges while
# complying with the principle of least privilege. Services which may connect
# for several different reasons should connect this way. For example,a web
# server may connect to authenticate or authorize users, and web applications
# it serves may also connect for different reasons.
#
# Example use:
# \begin{verbatim}
# postgresql::identmap { "auth":
#   os_user => 'foozy',
#   ensure => present,
#   db_users => ['foozy', 'foozy_dba'],
# }
# \end{verbatim}
#
# The title of the resource is the database to which to grant access. The
# os\_user is the operating system user who should be able to get in (or not).
# db\_users specifies the users as which this operating system user should be
# able to access the database. As with many other resource types, there is an
# \verb!ensure! parameter which defaults to present but can be set to absent.
# If you write \verb!ensure => absent!, the operating system user will be
# denied all access to the database. 
#
# \dinkus

define postgresql::identmap(
        $ensure = 'present',
        $os_user,
        $db_users = [$os_user]) {

# Least surprise: if someone hands an empty list for db\_users, they probably
# mean that this os\_user should not be able to get into the database at all.
    if $db_users == [] {
        $ensure = 'absent'
    }

    $database = $name

# This is part of an Augeas context, thus the /files.
    $pgconfs = "/files/var/lib/pgsql/data"

    include postgresql

# All the changes we make to the PostgreSQL configuration require that the
# configuration exists first, and cause the service to be restarted.
    Augeas {
        require => Exec['postgresql_initdb'],
        notify => Service['postgresql'],
    }

    augeas { "pg_hba_identmap_for_${database}":
        context => "$pgconfs/pg_hba.conf",
        changes => [
# This ident map will be the only way to get into this database, at least
# locally.
            "rm  *[type='local' and database='${database}']",
            "set 999/type      local",
            "set 999/database  '${database}'",
# This ident map will apply to all users trying to get into this database.
            "set 999/user      'all'",
            "set 999/method    ident",
            "set 999/method/option 'map=${database}'",
        ],
    }

    case $ensure {
        'present': {
# When we create many \verb!postgresql::identmap::entry! resources below, each
# instance of the defined resource contains an Augeas resource, and none of
# those Augeas resources know about each other. So we cannot use the same
# pattern as above, where we tell Augeas to remove everything and then add what
# we want, because each Augeas resource would remove the changes wrought by all
# the others.  Consequently \verb!identmap_entry! does not remove anything from
# the \verb!pg_ident.conf!, it only adds things.
#
# So let's remove everything which wasn't specified in the manifest.

            $not_our_os_user = "os_user != '${os_user}'"

# This is going to look like \verb*"db_user != 'foo' and db_user != 'bar'"*.
            $not_any_of_our_db_users = inline_template(
                '<%= db_users.map {|x| 
                        "db_user != \'#{x}\'"
                     }.join(" and ") -%>')

            include augeas     # non-stock lens required
            augeas { "pg_ident_restrict_for_${database}":
                context => "$pgconfs/pg_ident.conf",
                changes => [
                    "rm *[map='${database}' and \
                          os_user='${os_user}' and \
                          ${not_any_of_our_db_users}]",
                ],
            }

# Now, we add everything which is specified.

            postgresql::identmap::entry { $db_users:
                os_user => $os_user,
                database => $database,
            }
        }

# Support removing an OS user from ability to connect to a database.
        'absent': {
            include augeas
            augeas { "pg_ident_remove_${os_user}_into_${database}":
                context => "$pgconfs/pg_ident.conf",
                changes => [
                    "rm *[map='${database}' and \
                          os_user='${os_user}']",
                ],
            }
        }
    }
}
