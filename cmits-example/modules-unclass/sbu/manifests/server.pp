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

class sbu::server(
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
    apache::config::nss_site { 'sbu':
        content => template('sbu/sbu.conf'),
    }
    # there are some configurations that aren't included in the nss
    # site config file
    file { '/etc/httpd/conf.d':
        owner => root, group => 0, mode => 0600,
        source => 'puppet:///modules/sbu/etc-httpd-conf.d',
    }

    if $mode == 'production' {
        include sbu_fouo::data_structure
    }

    include python
    class { 'sbu::auth_db':
        mode      => $mode,
        builder   => $builder,
    }

    package {
        [
            "mod_perl",
            "mod_wsgi",
            "mod_dav_svn",
            "mod_authz_ldap",
            "mod_auth_pgsql",
            "python-coverage",
            "python-nose",
            "python-cheetah",
            "python-formencode",
            "python-psycopg2",
            "python-ldap",
            "pyOpenSSL",
            "make",
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
# Follow approved trust path from DoD CAs to Australian Defence Organization (ADO) CAs.
    pki::nss::australia { $dbdir:
        pwfile => "$dbdir/pwfile",
        sqlite => false,
    }
    pki::nss::crl { "mod_nss":
        dbdir => $dbdir,
        pwfile => "${dbdir}/pwfile",
        http_proxy => $http_proxy,
        sqlite => false,
    }

    include sbu::trac

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

# \implements{appsecstig}{APP3360} ``Protect access to authentication data by
# restricting access to authorized users and services.''
#
# No authentication data is hardcoded in the application, of course (APP3350),
# only written in the configuration; but this is also where we control access
# to the files that make up the application.
#
# \implements{iacontrol}{DCSL-1}\implements{databasestig}{DG0019}%
# Ensure that ``application software and configuration files'' dependent on the
# database are owned by ``the software installation account or the designated
# owner account,'' in the context of the AFSEO SBU system.
#
# It is possible that APP3360 does not regard file permissions. But they still
# need to be set.
#
# On development systems and those undergoing installation, the builder of the
# database should own the code, and not be prevented from writing to it.
    $os_app_owner = $mode ? {
        'development'  => $builder,
        'installation' => $builder,
        default        => root,
    }
    $os_exec_perms = $mode ? {
        'development'  => 0750,
        'installation' => 0550,
        default        => 0550,
    }
    $os_noexec_perms = $mode ? {
        'development'  => 0640,
        'installation' => 0440,
        default        => 0440,
    }

    file { [
            '/var/www/sbu-apps',
            '/var/www/sbu-apps/authapp',
            '/var/www/sbu-apps/authapp/config',
            '/var/www/sbu-apps/upload',
            '/var/www/sbu-apps/upload/config',
           ]:
        ensure => directory,
        owner => $os_app_owner,
        group => apache,
        mode => $os_noexec_perms,
        recurse => true,
        recurselimit => 4,
        require => Package['httpd'],
    }

    # things that should be executable
    file { [
            '/var/www/sbu-apps/authapp/public/go.py',
            '/var/www/sbu-apps/upload/public/go.py',
            '/var/www/sbu-apps/authapp/script/approve_cron.py',
            '/var/www/sbu-apps/authapp/script/expire_cron.py',
            '/var/www/sbu-apps/authapp/script/expiringSoon_cron.py',
            '/var/www/sbu-apps/authapp/script/inactivity_cron.py',
            ]:
        owner => $os_app_owner,
        group => apache,
        mode => $os_exec_perms,
        require => Package['httpd'],
    }

# Put symlinks in place for things that need to happen every morning.
    file {
        '/etc/cron.morningly/sbu_approve_cron':
            ensure => present,
            owner => root, group => 0, mode => 0700,
            content => "#!/bin/sh\n\
/sbin/runuser apache -s /bin/sh -c \
  /var/www/sbu-apps/authapp/script/approve_cron.py\n";

        '/etc/cron.morningly/sbu_expire_cron':
            ensure => present,
            owner => root, group => 0, mode => 0700,
            content => "#!/bin/sh\n\
/sbin/runuser apache -s /bin/sh -c \
  /var/www/sbu-apps/authapp/script/expire_cron.py\n";

        '/etc/cron.morningly/sbu_expiringSoon_cron.py':
            ensure => present,
            owner => root, group => 0, mode => 0700,
            content => "#!/bin/sh\n\
/sbin/runuser apache -s /bin/sh -c \
  /var/www/sbu-apps/authapp/script/expiringSoon_cron.py\n";

 # FIXME: we name the ssl activity log both here and in the templated
 # httpd config. Come up with a variable for this.

        '/etc/cron.morningly/sbu_inactivity_cron.py':
            ensure => present,
            owner => root, group => 0, mode => 0700,
            content => "#!/bin/sh
cat /var/log/httpd/ssl_activity_log | \\
  /sbin/runuser apache -s /bin/sh -c \\
    /var/www/sbu-apps/authapp/script/inactivity_cron.py
";
    }


# The DocumentRoot for the password-based Subversion virtual site needs to
# exist. Nothing needs to be in it, because the only thing served is the
# Subversion repositories, which mod\_dav\_svn takes care of.
    file { '/var/www/svn-html':
        ensure => directory,
        owner => root, group => apache, mode => 0755,
        require => Package['httpd'],
    }

# Install the SELinux rules that let SBU apps log errors through the syslog.
    $selmoduledir = "/usr/share/selinux/targeted"
    file { "${selmoduledir}/sbu_apps.pp":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/sbu/selinux/\
sbu_apps.selinux.pp",
    }
    selmodule { "sbu_apps":
       ensure => present,
       syncversion => true,
    }

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
