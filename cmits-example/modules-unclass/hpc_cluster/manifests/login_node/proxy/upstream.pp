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
# Use this class when the proxy that the login node offers to the HPC
# cluster internal network should in turn use a proxy to access the
# Net.

class hpc_cluster::login_node::proxy::upstream(
    $host,
    $port,
    $dontproxy_domain)
{
    include hpc_cluster::login_node::proxy

    augeas { 'squid upstream proxy for cluster login':
        context => '/files/etc/squid/squid.conf',
        changes => [
            'rm acl[dontproxy_dns][position() > 1]',
            'set acl[dontproxy_dns]/dontproxy_dns/type dstdomain',
            "set acl[dontproxy_dns]/dontproxy_dns/setting \
             ${dontproxy_domain}",
            'rm acl[dontproxy_ip][position() > 1]',
            'set acl[dontproxy_ip]/dontproxy_ip/type dst',
            "set acl[dontproxy_ip]/dontproxy_ip/setting \
             ${hpc_cluster::login_node::proxy::internal_ipv4_subnet}",
            "set cache_peer \
             '${host} parent ${port} 0 no-query default'",
            "set cache_peer_access \
             '${host} deny dontproxy_dns dontproxy_ip'",
            'rm acl[localnet][position() > 1]',
            'set acl[localnet][1]/localnet/type src',
            "set acl[localnet][1]/localnet/setting \
             '${internal_ipv4_subnet}'",
        ],
        require => Package['squid'],
        notify => Service['squid'],
    }
}

