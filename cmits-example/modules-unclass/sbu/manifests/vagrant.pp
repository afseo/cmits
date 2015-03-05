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
class sbu::vagrant(
    $mode = 'development',
    $builder = 'vagrant')
{
    class { 'sbu::server':
        mode => $mode,
        builder => $builder,
        cert_nickname => $::hostname,
    }
    pki::nss::self_signed { "${sbu::server::dbdir}:${::hostname}":
        sqlite => false,
        noise_file => '/vagrant/insecure_noisefile',
    }
    file { '/etc/httpd/conf.d/Data.perms':
        ensure => present,
        owner => root, group => 0, mode => 0600,
        content => '',
    }
}
