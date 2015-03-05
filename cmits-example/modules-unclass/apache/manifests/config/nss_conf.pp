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
class apache::config::nss_conf($nss_database_dir) {
    include apache

    if $::osfamily != 'RedHat' or $operatingsystemrelease !~ /^6\./ {
        unimplemented()
    }

    $nss_sites_dir = '/etc/httpd/nss-site.d'
    $rel_nss_sites_dir = 'nss-site.d'
    $abbr_ehcnc  = '/etc/httpd/conf.d/nss.conf'
    $abbr_fehcnc = "/files/${abbr_ehcnc}"

    Augeas {
        incl => $abbr_ehcnc,
        lens => 'Httpd.lns',
        notify => Service['httpd'],
    }

# Ensure a directive is in place and set to a given value, in the
# toplevel of nss.conf.
    define toplevel_directive($arguments) {
        $abbr_ehcnc = $apache::config::nss_conf::abbr_ehcnc
        directive { "${abbr_ehcnc}:${name}":
            context_in_file => "",
            arguments => $arguments,
        }
    }

    toplevel_directive {
# \implements{apachestig}{WA00555 A22} Listen on a specific IP
# address, so that if interfaces are added in the future we will not
# accidentally serve web pages on them by default.
        'Listen':
            arguments => ["${::ipaddress}:443"];
        'NSSPassPhraseDialog':
            arguments => ["file:${nss_database_dir}/pwfile"];
    }

# We are going to move the virtual host section to its own config
# file.
    augeas { 'remove stock virtualhost from nss.conf':
        incl => $abbr_ehcnc,
        lens => 'Httpd.lns',
        context => $abbr_fehcnc,
        changes => 'rm VirtualHost[arg="_default_:8443"]',
    }
    file { $nss_sites_dir:
        ensure => directory,
        owner => root, group => 0, mode => 0600,
    } ->
    toplevel_directive {
        'Include': arguments => ["${rel_nss_sites_dir}/*.conf"];
    }
}
