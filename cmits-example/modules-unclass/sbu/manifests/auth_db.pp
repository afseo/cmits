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
# \subsection{The auth database}
#
# The \verb!auth! database on an SBU server contains the list of users and
# groups, which the web server consults when making authentication and
# authorization decisions.
#
# Requirements marked implemented in this section are only implemented in the
# context of the SBU system. See
# \url{https://afseo.eglin.af.mil/projects/ihaaa/ticket/375}.
#
# The mode parameter must be one of `production', `installation' or
# `development'. If installation or development, the builder must be specified.
# This is the OS user who will be allowed to (re)build the auth database.

class sbu::auth_db(
        $mode = 'production',
        $builder = 'jenninjl') {

# Data in the auth database is security information, so all changes to it
# should be audited.
    class { 'postgresql':
        audit_data_changes => true,
    }

# Do all database administration as \verb!puppet_dba!.
    Pgsql_role {
        os_user =>  'puppet_dba',
        db_user =>  'puppet_dba',
        database => 'puppet_dba',
    }
    Pgsql_database {
        os_user =>  'puppet_dba',
        db_user =>  'puppet_dba',
        database => 'puppet_dba',
    }

# \implements{iacontrol}{ECLP-1}\implements{databasestig}{DG0124}%
# Prevent the misuse of DBA accounts for non-administrative purposes by
# creating an object owner user.
#
# \implements{iacontrol}{ECLP-1}\implements{databasestig}{DG0004}%
# Disable the application object owner user ``when not performing installation
# or maintenance actions.''
    pgsql_role { "sbu_aoou":
        login => $mode ? {
            'installation' => true,
            'development'  => true,
            default        => false,
        },
        inherit => true,
    }

    pgsql_database { "auth":
        owner => "sbu_aoou",
    }

# SBU-specific roles. Permissions regarding database objects are granted to
# these roles by the SQL scripts which create the database objects.
    pgsql_role {
        'sbu_mod_auth_pgsql_access_log_r':;
        'sbu_mod_auth_pgsql_authnz_r':;
        'sbu_authapp_r':;
        'sbu_authapp_auto_testing_r':;
        'sbu_authorization_finder_r':;
# Now, SBU-specific users.
        'sbu_authapp':
            login => true,
            inherit => true,
            grant_roles => $mode ? {
                'development' => [
                    'sbu_authapp_r',
                    'sbu_authapp_auto_testing_r',
                ],
                default => [
                    'sbu_authapp_r',
                ],
            };
        'sbu_mod_auth_pgsql':
            login => true,
            inherit => true,
            grant_roles => [
                'sbu_mod_auth_pgsql_access_log_r',
                'sbu_mod_auth_pgsql_authnz_r',
            ];
        'sbu_upload':
            login => true,
            inherit => true,
            grant_roles => 'sbu_authorization_finder_r';
    }

    case $mode {
        'development', 'installation': {
            pgsql_role { $builder:
                grant_roles => ['sbu_aoou'],
                createdb => true,
                login => true,
                inherit => true,
            }
        }
    }

# Configure \verb!pg_hba.conf! and \verb!pg_ident.conf! to let people connect
# to auth using an ident map. This is not yet automated.
# \begin{tabular}{l l}
# \textbf{OS user} & \textbf{can connect with DB username} \\
# {\tt apache} & {\tt sbu\_mod\_auth\_pgsql} \\
# {\tt apache} & {\tt sbu\_authapp} \\
# {\tt apache} & {\tt sbu\_upload} \\
# developers & {\tt sbu\_authapp} \\
# developers and installers & {\tt sbu\_aoou} \\
# \end{tabular}
}
