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
# \subsection{Server deployment}
#
# The mode parameter must be one of `production', `installation' or
# `development'. If installation or development, the builder must be specified.
# This is the OS user who will be allowed to (re)build the auth database.

class searde_svn::server(
        $mode = 'production',
        $builder = 'jenninjl',
        $cert_nickname = $::hostname,
        $http_proxy,
        $admin_email_address,
        $web_fqdn=$::fqdn,
    ) {
    $dbdir = "/etc/pki/mod_nss"
    class { 'apache':
        production => $mode ? {
            'production' => true,
            default      => false,
        }
    }
    class { 'apache::config':
        nss_database_dir => $dbdir,
# Max request body size is 8 gigabytes.
        max_request_body => 8589934592,
    }
    apache::config::nss_site { 'searde_svn':
        content => template('searde_svn/searde_svn.conf'),
    }
    # there are some configurations that aren't included in the nss
    # site config file
    file { '/etc/httpd/conf.d':
        owner => root, group => 0, mode => 0600,
        source => 'puppet:///modules/searde_svn/etc-httpd-conf.d',
    }


    include python

    package {
        [
            "mod_wsgi",
            "mod_dav_svn",
        ]:
            ensure => present,
    }

    pki::nss::db { $dbdir:
        owner => apache, group => 0, mode => 0600,
        sqlite => false,
        pwfile => true,
    }
    pki::nss::dod_roots { $dbdir:
        pwfile => "$dbdir/pwfile",
        sqlite => false,
    }
    pki::nss::dod_cas { $dbdir:
        pwfile => "$dbdir/pwfile",
        sqlite => false,
    }
# No e-mail CAs: we want TortoiseSVN not to ask the user whether to use
# identity or email signing cert \emph{ad nauseam}.
    pki::nss::eca_roots { $dbdir:
        pwfile => "$dbdir/pwfile",
        sqlite => false,
    }
    pki::nss::eca_cas { $dbdir:
        pwfile => "$dbdir/pwfile",
        sqlite => false,
    }
    pki::nss::crl { "mod_nss":
        dbdir => $dbdir,
        pwfile => "${dbdir}/pwfile",
        http_proxy => $http_proxy,
        sqlite => false,
    }

    include searde_svn::trac

# We can't put things under \verb!/var/www! if \verb!/var/www! doesn't
# exist. That directory is put in place by the \verb!httpd!
# package. When we depend on the whole \verb!apache! class, dependency
# cycles happen, so we have to depend on the package.

    file { "/var/www/virus-checkpoint":
        ensure => directory,
        owner => apache, group => 0, mode => 0700,
        require => Package['httpd'],
    }

# Make sure everyone can read the public things.

    file { "/var/www/html/styles":
        ensure => directory,
        owner => root, group => 0, mode => 0644,
        require => Package['httpd'],
    }
    file { "/var/www/html/pages":
        ensure => directory,
        owner => root, group => 0, mode => 0644,
        require => Package['httpd'],
    }

# TODO THESE COULD BE MOVED TO APACHE MODULE
# Install some convenience scripts. These would work for any web server where
# the Apache log messages are directed to the system log; but at present there
# is no policy-based means by which Apache is configured to do this, so it's up
# to the (SBU-specific) Apache configuration.
    file {

        "/usr/local/bin/tail_httpd_access":
            ensure => present,
            owner => root, group => 0, mode => 0755,
            content => "#!/bin/sh\n\
/usr/bin/tail -f /var/log/messages | \
grep --line-buffered httpd__access\n";

        "/usr/local/bin/tail_httpd_error":
            ensure => present,
            owner => root, group => 0, mode => 0755,
            content => "#!/bin/sh\n\
/usr/bin/tail -f /var/log/messages | \
grep --line-buffered 'httpd[^_]'\n";

        "/usr/local/bin/tail_httpd":
            ensure => present,
            owner => root, group => 0, mode => 0755,
            content => "#!/bin/sh\n\
/usr/bin/tail -f /var/log/messages | \
grep --line-buffered httpd\n";

        "/usr/local/bin/HR":
            ensure => present,
            owner => root, group => 0, mode => 0755,
            content => "#!/bin/sh\n\
/sbin/service httpd restart\n";

    }

# TODO Factor this into sub-class in apache module
# Let the authapp send mail. The \verb!httpd_can_sendmail! sebool
# appears to allow \verb!httpd_sys_script_t! to run an MTA user agent
# (like \verb!mail(1)!, perhaps), but not to open a TCP socket itself
# to talk to the MTA. For that we need two things:
#
# \begin{enumerate}
# \item The sebool \verb!httpd_can_network_connect!
# \item The SELinux contexts of the authapp CGI executable files to be set properly.
# \end{enumerate}
    selboolean { 'httpd_can_network_connect':
        value => on,
        persistent => true,
    }
}
