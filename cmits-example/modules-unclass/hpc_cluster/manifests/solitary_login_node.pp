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
# \subsection{Solitary login node}
#
# This is just like \verb!login_node! but is used in the case where the login
# node is not redundant.

class hpc_cluster::solitary_login_node(
        $internal_ipv4_first_two_octets,
        $internal_infiniband_ipv4_first_two_octets,
        $external_interface = 'eth0',
        $internal_interface = 'eth1',
        $compute_node_count,
        $use_infiniband='false',
        ) {

    $iifto = $internal_ipv4_first_two_octets
    $login_internal_ipv4 = "${iifto}.1.1"
    $login1_internal_ipv4 = "${iifto}.1.2"
    $iibifto = $internal_infiniband_ipv4_first_two_octets
    $login1_internal_infiniband_ipv4 = "${iibifto}.1.2"

    class { 'hpc_cluster::login_node':
        internal_ipv4_first_two_octets =>
                $internal_ipv4_first_two_octets,
        internal_infiniband_ipv4_first_two_octets =>
                $internal_infiniband_ipv4_first_two_octets,
        internal_ipv4_address =>
                $login1_internal_ipv4,
        internal_infiniband_ipv4_address =>
                $login1_internal_infiniband_ipv4,
        compute_node_count =>
                $compute_node_count,
        use_infiniband => $use_infiniband,
        internal_interface => $internal_interface,
        external_interface => $external_interface,
    }

# Configure the alias on the internal network interface. Redundant
# login nodes will have heartbeat configuration to pass this IP
# address between themselves on failure, but solitary login nodes will
# just always hold the alias.
    $augeas_ifcfg = '/files/etc/sysconfig/network-scripts/ifcfg'
    augeas { "${hostname} ${cluster_hostname} internal solitary":
        context => "${augeas_ifcfg}-${internal_interface}",
        changes => [
            "set IPADDR2 ${login_internal_ipv4}",
            'set NETMASK2 255.255.0.0',
        ],
    }
}
