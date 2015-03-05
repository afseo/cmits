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
# \subsection{Roles inside PostgreSQL}
#
# This section sets out the roles in a PostgreSQL database.
#
# Administrative roles are the same across databases, because they do the same
# things; per-application roles are set out in per-application documents, but a
# pattern for them is set here.
#
# \implements{iacontrol}{ECLP-1,ECPA-1}\implements{databasestig}{DG0116,DG0117}%
# Grant database administrative privileges to database administrators using
# DBMS roles. 

class postgresql::roles {

# Do all DBA work as the \verb!puppet_dba! user.
    Pgsql_role {
        db_user => 'puppet_dba',
        os_user => 'puppet_dba',
        database => 'puppet_dba',
    }

# \implements{iacontrol}{ECPA-1}\implements{databasestig}{DG0117}%
# Grant administrative privileges solely via roles.
#
# ``The role attributes \verb!LOGIN!, \verb!SUPERUSER!, \verb!CREATEDB! and
# \verb!CREATEROLE! ... are never inherited as ordinary privileges on database
# objects are. You must actually \verb!SET ROLE! to a specific role having one
# of these attributes in order to make use of the attribute.''
# \cite[\S 20.4]{pgsql-documentation} So---
#
# \doneby{DBAs}{iacontrol}{ECLP-1}\doneby{DBAs}{databasestig}{DG0124}%
# A database administrator \verb!fnord!, to whom the \verb!dba! role below has
# been granted, must \verb!SET ROLE dba! before doing any database
# administration. Such a user should \verb!RESET ROLE! when done with the
# database administration.
#
# So, now, the roles with administrative privileges:
#
# DBA users create developer users on development database servers, and create
# application object owner users, application users, and per-application
# databases on test and production database servers.
    pgsql_role { 'dba':
        login => false,
        inherit => false,
        superuser => false,
        createdb => true,
        createrole => true,
    }

# Developer users create application object owner users, application users, and
# per-application databases on development database servers.
#
# Assignments 
    pgsql_role { 'developer':
        login => false,
        inherit => false,
        superuser => false,
        createdb => true,
        createrole => true,
    }

# \doneby{admins}{iacontrol}{ECLP-1}\doneby{admins}{databasestig}{DG0042}%
# Administrators must not use the \verb!postgres! user to do anything with the
# database: each, being provided with his own database user, must use that
# instead.
    pgsql_role { [
            'jenninjl_dba',
            'adamsgd_dba',
            'graymx_dba',
            'shawfra_dba',
            'cookch_dba',
            'queener_dba',
            'chappell_dba',
			'coulter_dba',
        ]:
        login => true,
        inherit => true,
# \implements{iacontrol}{ECLP-1}\implements{databasestig}{DG0085}%
# Avoid granting ``excessive or unauthorized'' privileges to DBAs, by
# preventing them from being superusers in the database. ``Although DBAs may
# assign themselves privileges,'' that action is logged when it happens, and
# privileges are reported monthly. See~\S\ref{class_postgresql::stig} for
# details.
        superuser => false,
        grant_roles => ['dba'],
    }
}

# \subsubsection{Pattern for application roles and permissions}
#
# This section should become a guide to what application-specific DBMS users
# should exist and what privileges they must have and must not have (mostly
# not). But it isn't written yet. Until it is,
# see~\S\ref{per-system-databasestig} for a more general list of what an
# application needs to do to comply with the Database STIG. (Given, of course,
# that it's running against a database server managed by this \CMITSPolicy .)
