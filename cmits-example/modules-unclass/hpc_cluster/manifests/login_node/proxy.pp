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
class hpc_cluster::login_node::proxy(
    $internal_ipv4_subnet) {

# Make HTTP and HTTPS available on the internal network.
    package { 'squid':
        ensure => installed,
    }
    augeas { 'squid for cluster login':
        context => '/files/etc/squid/squid.conf',
        changes => [
            'rm acl[localnet][position() > 1]',
            'set acl[localnet][1]/localnet/type src',
            "set acl[localnet][1]/localnet/setting \
             '${internal_ipv4_subnet}'",
        ],
        require => Package['squid'],
        notify => Service['squid'],
    }
    augeas { 'let cluster nodes use Puppet port':
        context => '/files/etc/squid/squid.conf',
        changes => [
            'defnode puppet_port acl[999] ""',
            'set $puppet_port/SSL_ports/type port',
            'set $puppet_port/SSL_ports/setting 8140',
            ],
        onlyif => "match acl[SSL_ports/type='port' and \
                             SSL_ports/setting='8140'] \
                   size == 0",
    }
    service { 'squid':
        enable => true,
        ensure => running,
    }
}
