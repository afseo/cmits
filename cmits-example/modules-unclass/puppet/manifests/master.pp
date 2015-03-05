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
# \subsection{Puppetmaster}

class puppet::master {

# This class is not (yet?) portable among Linux flavors or other OSes.
    if $::osfamily != "RedHat" {
        unimplemented()
    }

    include puppet::client
    package { [
        "puppet-server",
# Stored configs depend on Rails, which RHEL does not provide as RPMs, so we
# must install the gems.
        "rubygems",
        "ruby-pg",
        "ruby-devel",
        "postgresql-server",
    ]:
        ensure => installed,
    }

    package { "rails":
        provider => gem,
        ensure => installed,
        source => "",
    }

    file { "/etc/sysconfig/puppetmaster":
        owner => root, group => 0, mode => 0644,
        content => "\
PUPPETMASTER_LOG=syslog\n\
PUPPETMASTER_MANIFEST=/etc/puppet/manifests/site.pp\n",
        notify => Service['puppetmaster'],
    }

# Install the SELinux rules that let puppetmaster do its job.
    $selmoduledir = "/usr/share/selinux/targeted"
    file { "${selmoduledir}/puppetmaster.pp":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/puppet/\
puppetmaster.selinux.pp",
    }
    selmodule { "puppetmaster":
       ensure => present,
       syncversion => true,
       notify => Service['puppetmaster'],
    }

    selboolean { "puppetmaster_use_db":
        value => on,
        persistent => true,
        notify => Service['puppetmaster'],
    }

# We are no longer using the WEBrick based puppetmaster server.
    service { 'puppetmaster':
        enable => false,
        ensure => stopped,
    }

# We're now using the one based on Apache and Passenger.
    service { 'httpd':
        enable => true,
        ensure => running,
    }

# Fix some permissions roiled by other parts of the policy. If these are not
# fixed, the puppetmaster will try to fix them by chmodding files; and the
# SELinux policy says that things that httpd runs have no business chmodding
# anything. This results in 500 Internal Server Errors, rather than catalogs
# being served to clients.
#
# Furthermore, these cannot be written as file resources, because then they
# become part of the very catalog that the puppetmaster is incapable of
# serving---even to itself---so the problem must be fixed outside Puppet.
#
# The \verb!/var/lib/puppet/lib! files must be readable by the
# \verb!puppet! user because they contain Ruby code required by custom
# types; the Puppet master must import this code to compile manifests.
    $abbr_mhl = '/var/log/puppet/masterhttp.log'
    $abbr_cas = '/var/lib/puppet/ssl/ca/serial'
    $abbr_lib = '/var/lib/puppet/lib'
    cron { 'fix_puppetmaster_perms':
        command => "chown puppet:puppet $abbr_mhl; \
                    chmod 0660 $abbr_mhl; \
                    chown puppet:puppet $abbr_cas; \
                    chmod 0644 $abbr_cas; \
                    chown -R root:puppet $abbr_lib; \
                    chmod -R g+rX $abbr_lib; \
                   ",
        user => root,
        minute => '*/5',
    }

# Some other permissions don't get in the way of the puppetmaster
# serving itself a catalog, but do get in the way of manifests being
# compiled into catalogs for other nodes.
    file { '/var/lib/puppet/lib':
        owner => root, group => puppet, mode => 0640,
        recurse => true, recurselimit => 9,
    }

# Copy the \verb!expect_and_sign! scripts into place. These adapt between
# Puppet's workflow, where certs are signed immediately after CSRs are
# generated on the client, and AFSEO's workflow, where we want to do most of
# the work when we receive notification that a new system will be coming
# online, not just after the system does come online.
#
# These can't go in \verb!/usr/local/sbin! because of the settings in
# root's \verb!.bashrc!; see~\S\ref{class_root::stig}.

    file { '/usr/sbin/sign_expected':
        owner => root, group => 0, mode => 0755,
        source => 'puppet:///modules/puppet/sign_expected',
    }
    file { '/usr/sbin/expect_host':
        owner => root, group => 0, mode => 0755,
        source => 'puppet:///modules/puppet/expect_host',
    }
    file { '/usr/sbin/unexpect_host':
        owner => root, group => 0, mode => 0755,
        ensure => symlink,
        target => 'expect_host',
    }
    file { '/var/spool/sign_expected':
        ensure => directory,
        owner => root, group => 0, mode => 0700,
    }
    exec { 'run sign_expected at boot':
        unless => 'grep sign_expected /etc/rc.local',
        command => 'sed -i "/^touch/i \
/usr/sbin/sign_expected >&/var/log/sign_expected.log &" \
                    /etc/rc.local',
    }

# Let admins run these scripts.
    sudo::auditable::command_alias { 'CMITS_PUPPET_SIGN_SCRIPTS':
        type => 'exec',
        commands => [
            '/usr/sbin/expect_host',
            '/usr/sbin/unexpect_host',
            '/usr/sbin/sign_expected',
            ],
    }


    include subversion::pki::trust_cas
    
# Provide for admins to easily manually update the policy.
    file { '/usr/sbin/sudo_update_cmits_policy':
        owner => root, group => 0, mode => 0755,
        content => "#!/bin/sh
/usr/bin/sudo /usr/bin/svn --non-interactive up /etc/puppet
/usr/bin/sudo /sbin/restorecon -R /etc/puppet
/usr/bin/sudo /bin/chown -R puppet /etc/puppet
",
    }

# Update the policy every hour.
    file { '/usr/sbin/update_cmits_policy':
        owner => root, group => 0, mode => 0700,
        content => "#!/bin/sh
/usr/bin/svn --non-interactive -q up /etc/puppet
/sbin/restorecon -R /etc/puppet
/bin/chown -R puppet /etc/puppet
",
    }
    cron { 'update_cmits_policy':
        hour => absent,
        minute => '*/10',
        command => '/usr/sbin/update_cmits_policy',
        require => File['/usr/sbin/update_cmits_policy'],
        user => root,
    }

# Remove old reports, to avoid filling up the filesystem used for
# logs.
#
# GNU-ism: \verb!xargs -r!.
    cron { 'remove_old_logs':
        hour => 3,
        command => "/usr/bin/find /var/lib/puppet/reports \
                       -mtime +10 -type f -name \\*.yaml | \
                    /usr/bin/xargs -r -n 100 /bin/rm",
        user => root,
    }
}
