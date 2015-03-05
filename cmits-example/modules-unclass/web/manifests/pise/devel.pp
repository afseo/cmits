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
# \subsubsection{Development machine}
#
# PISE developers need Pylons, and may need a database server, but do not need
# a working web server. Or, at least, not yet.

class web::pise::devel {
    include apache
    include python

    package {
        [
            "mod_wsgi",
            "mod_authz_ldap",
            "mod_auth_pgsql",
            "postgresql-server",
            "python-coverage",
            "python-nose",
            "python-cheetah",
            "python-formencode",
            "python-psycopg2",
            "python-pylons",
            "make",
        ]:
            ensure => present,
    }

}
