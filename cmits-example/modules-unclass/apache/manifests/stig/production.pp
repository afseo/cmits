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
# \subsubsection{Apache STIG compliance on production web servers}

class apache::stig::production {

    include apache::stig::common

# \implements{apachestig}{WG080 A22}%
# Remove compilers from production web servers.
#
# (We do not detect here whether a web server is ``production.'')

    package {
        [
            'gcc',
            'gcc-c++',
            'gcc-gfortran',
            'libtool',
            'systemtap',
# No one should be building modules on the web server.
            'httpd-devel',
        ]:
            ensure => absent,
    }

# \implements{apachestig}{WG385 A22}%
# Remove all web server documentation, sample code, example applications and
# tutorials from production web servers.
#
# As above, we do not detect a production web server here. Since this is the
# only Category I requirement in this STIG, we'll make sure that it works
# across \verb!httpd! versions, rather than being a piece of tidy policy.

    exec { "rm_httpd_docs":
        command => "/bin/rm -rfv /usr/share/doc/httpd-[0-9]*",
        onlyif  => "/bin/ls      /usr/share/doc/httpd-[0-9]*",
        logoutput => true,
    }
    file {
        '/usr/share/man/man8/apachectl.8.gz':
            ensure => absent;
        '/usr/share/man/man8/htcacheclean.8.gz':
            ensure => absent;
        '/usr/share/man/man8/httpd.8.gz':
            ensure => absent;
        '/usr/share/man/man8/rotatelogs.8.gz':
            ensure => absent;
        '/usr/share/man/man8/suexec.8.gz':
            ensure => absent;
    }
    exec { "rm_mod_nss_docs":
        command => "/bin/rm -rfv /usr/share/doc/mod_nss-[0-9]*",
        onlyif  => "/bin/ls      /usr/share/doc/mod_nss-[0-9]*",
        logoutput => true,
    }
    package {
        "httpd-manual": ensure => absent;
# The debuginfo package may contain the source, which is the ultimate
# documentation.
        "httpd-debuginfo": ensure => absent;
    }
}
