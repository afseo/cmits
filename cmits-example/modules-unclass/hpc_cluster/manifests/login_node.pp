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
# \subsection{Login node}
#
# To serve its internal network a login node must make available NTP, DNS,
# HTTP, HTTPS, Puppet, and likely NFS. We do this as far as possible without
# packet forwarding, because it seems usual in the DoD to avoid configurations
# that, while easy, may make it less clear which hosts are generating traffic
# and which forwarding it.
#
# The \verb!cluster_hostname! parameter is used in other resources to identify
# the cluster we're talking about, so it should be unique across all cluster
# hostnames in your Puppet manifest. The default value for this is the hostname
# of the cluster login node. If your cluster login nodes are called
# \verb!fnord1!, \verb!fnord2!, etc., you'll have to set
# \verb!cluster_hostname! to \verb!fnord! manually, and \verb!cluster_fqdn! to
# \verb!fnord.example.com!.
#
# \verb!internal_ipv4_first_two_octets! should be set to the first two octets
# of the cluster's internal network, delimited by a dot, like \verb!"10.24"!.
#
# \verb!internal_ipv4_address! is the internal IPv4 address of this login node;
# follow the cluster IP address plan in~\S\ref{module_hpc_cluster}.
#
# \verb!internal_infiniband_ipv4_first_two_octets! is the subnet to
# use for Infiniband; this should normally be one more than
# \verb!internal_ipv4_first_two_octets!, such that if the latter is
# \verb!10.24!, the former is \verb!10.25!.

class hpc_cluster::login_node(
        $internal_ipv4_first_two_octets,
        $internal_ipv4_address,
        $use_infiniband = 'false',
        $internal_infiniband_ipv4_first_two_octets,
        $internal_infiniband_ipv4_address,
        $compute_node_count,
        $compute_node_third_octet = "50",
        $cluster_hostname = $::hostname,
        $cluster_fqdn = $::fqdn,
        $external_interface = 'eth0',
        $internal_interface = 'eth1',
        $infiniband_interface = 'ib0',
        ) {

# \verb!$cluster_hostname! is used in the \verb!hpc_cluster::node!
# class to collect resources exported by this class, so having
# multiple clusters with the same hostname in different domains in the
# same sphere of Puppet management is not supported by this module.
    tag $cluster_hostname

    $dnsmasq_hosts_file = '/etc/dnsmasq.hosts'
    $iifto = $internal_ipv4_first_two_octets
    $iibifto = $internal_infiniband_ipv4_first_two_octets
    $internal_ipv4_subnet = "${iifto}.0.0/16"
    $internal_ipv4_with_netmask = "${iifto}.0.0/255.255.0.0"
    $compute_node_first_three_octets = "${iifto}.${compute_node_third_octet}"
    $compute_node_infiniband_first_three_octets = "${iibifto}.${compute_node_third_octet}"
    $login_internal_ipv4 = "${iifto}.1.1"

    $login1_fqdn = inline_template("<%=
        short_name, domain = cluster_fqdn.split('.', 2);
        short_name + '1.' + domain %>")
    $login2_fqdn = inline_template("<%=
        short_name, domain = cluster_fqdn.split('.', 2);
        short_name + '2.' + domain %>")


# Cheat: we assume RHEL 6 here, because its default squid configuration is very
# close to what we want. And no one wants an \verb!hpc_cluster::login_node!
# that isn't running RHEL6, yet.
    if $::osfamily != 'RedHat' or $::operatingsystemrelease !~ /^6\..*/ {
        unimplemented()
    }

# Make DNS available on the internal network. This will include whatever is
# written in the \verb!/etc/hosts! file on the login node---which we will get
# to shortly.
    package { 'dnsmasq':
        ensure => installed,
    }

    augeas { 'dnsmasq for cluster login':
        context => '/files/etc/dnsmasq.conf',
        changes => [
            "set interface         ${internal_interface}",
# Don't serve DHCP: the management node will do that.
            "set no-dhcp-interface ${internal_interface}",
# Don't bind to every interface, but only the ones given above. This seems to
# resonate with security principles originally espoused in the Apache httpd
# STIG. (\verb!clear! means don't set a value, but make sure it exists.)
            "clear bind-interfaces",
            "clear expand-hosts",
# We'll set up a subdomain by the name of the cluster. This way we get to use
# generic names inside the subdomain, like \verb!head1!.
            "set domain            ${cluster_fqdn}",
        ],
        require => Package['dnsmasq'],
        notify => Service['dnsmasq'],
    }

# We need to know the IPs of compute nodes on the login node, so we
# can ssh to them, so we can support interactive jobs like debuggers.
# The management node knows this information, but under Scyld it
# doesn't share the information in a way the login node can consume
# it, so we have to write this in /etc/hosts on the login node.
#
# But dnsmasq usually serves everything in /etc/hosts up using DNS. We
# don't want the compute nodes to be able to get their own addresses
# both from the master node via bproc and from the login node via DNS:
# grief lies that way. So we need to make dnsmasq serve information
# from a separate file, not /etc/hosts.
    augeas { 'dnsmasq hosts file setting':
        context => '/files/etc/dnsmasq.conf',
        changes => [
            $dnsmasq_hosts_file ? {
                '/etc/hosts' => '',
                default      => 'clear no-hosts',
            },
            "set addn-hosts ${dnsmasq_hosts_file}",
            ],
        require => Package['dnsmasq'],
        notify => Service['dnsmasq'],
    }

    service { 'dnsmasq':
        enable => true,
        ensure => running,
    }

# NTP is taken care of by NTP classes which are specific to the
# network where the cluster lives. That will include the \verb!ntp!
# module (\ref{module_ntp}).
#
# Here's how we share NTP with the inside of the cluster network:
    @@augeas { "${cluster_hostname} ntp.conf":
        context => "/files/etc/ntp.conf",
        changes => [
# Remove comments about pool.ntp.org: they are not useful here.
            "rm #comment[. =~ regexp('.*pool.ntp.org.*')]",
            "rm server",
            "set server[1] login1",
# If login2 doesn't exist, ntpd won't mind much.
            "set server[2] login2",
        ],
    }

#
# Set up some addresses inside the cluster.
#
# The entry containing the \verb!cluster_fqdn! is pretty special, because it
# appears Centrify uses the canonical name on that line as the hostname when
# joining Active Directory. So if you have
#
# \begin{verbatim}
# x.y.z.w   flarble the.hosts.fqdn
# \end{verbatim}
#
# Centrify should rightfully use \verb!the.hosts.fqdn! when joining AD, but
# instead it uses \verb!flarble!. So the FQDN has to come first on the line.
#
# These host entries should be both in the dnsmasq.hosts and hosts
# files, so we write them in a variable.
    $cluster_login_nodes_gbe_host_entries_script = "
rm *[canonical='head']
set 990/ipaddr    ${iifto}.0.1
set 990/canonical head
set 990/alias     head.${cluster_fqdn}
rm *[canonical='head1']
set 991/ipaddr    ${iifto}.0.2
set 991/canonical head1
set 991/alias     head1.${cluster_fqdn}
rm *[canonical='head2']
set 992/ipaddr    ${iifto}.0.3
set 992/canonical head2
set 992/alias     head2.${cluster_fqdn}
rm *[canonical='login']
rm *[canonical='${cluster_fqdn}']
set 993/ipaddr    ${login_internal_ipv4}
set 993/canonical ${cluster_fqdn}
set 993/alias[1]  login
set 993/alias[2]  login.${cluster_fqdn}
rm *[canonical='login1']
rm *[canonical='${cluster_fqdn}']
set 994/ipaddr    ${iifto}.1.2
set 994/canonical ${cluster_fqdn}
set 994/alias[1] login1
set 994/alias[2]  login1.${cluster_fqdn}
set 994/alias[3]  ${login1_fqdn}
rm *[canonical='login2']
set 995/ipaddr    ${iifto}.1.3
set 995/canonical login2
set 995/alias[1]  login2.${cluster_fqdn}
set 995/alias[2]  ${login2_fqdn}
"

    $cluster_login_nodes_infiniband_host_entries_script = "
rm *[canonical='head1-ib']
set 980/ipaddr    ${iibifto}.0.2
set 980/canonical head1-ib
set 980/alias     head1-ib.${cluster_fqdn}
rm *[canonical='head2-ib']
set 981/ipaddr    ${iibifto}.0.3
set 981/canonical head2-ib
set 981/alias     head2-ib.${cluster_fqdn}
"

    $cluster_login_nodes_host_entries_script = $use_infiniband ? {
        'true' => "
${cluster_login_nodes_gbe_host_entries_script}
${cluster_login_nodes_infiniband_host_entries_script}
",
        'false' => "
${cluster_login_nodes_gbe_host_entries_script}
",
    }

# Get the node IP addresses in the login node's \verb!/etc/hosts!
# file. These are needed for a few different things: (a) if you have
# Grid Engine interactive jobs, qsub needs to ssh to one of these
# addresses when you submit one of those; and (b) if you are mounting
# a Gluster volume using the Gluster client, the login node needs to
# speak to any node that has a brick on it, and for that to happen,
# both forward and reverse name lookups need to work OK.
#
# Assumption: you don't have 200 hosts already, and you don't have
# more than 200 compute nodes.
    $compute_nodes_host_entries_script = inline_template("
<% 0.upto(@compute_node_count.to_i - 1) do |nodenumber| %>
rm *[canonical='n<%=nodenumber -%>.${cluster_fqdn}']
set <%= nodenumber + 200 -%>/ipaddr ${compute_node_first_three_octets}.<%=nodenumber %>
set <%= nodenumber + 200 -%>/canonical n<%=nodenumber -%>.${cluster_fqdn}
set <%= nodenumber + 200 -%>/alias[1]  n<%=nodenumber %>
<%   if @use_infiniband == 'true' %>
rm *[canonical='n<%=nodenumber -%>-ib.${cluster_fqdn}']
set <%= nodenumber + 400 -%>/ipaddr ${compute_node_infiniband_first_three_octets}.<%=nodenumber %>
set <%= nodenumber + 400 -%>/canonical n<%=nodenumber -%>-ib.${cluster_fqdn}
set <%= nodenumber + 400 -%>/alias[1]  n<%=nodenumber -%>-ib
<%   end %>
<% end %>
")

    $host_entries_on_login_node = "
${cluster_login_nodes_host_entries_script}
${compute_nodes_host_entries_script}
"

    augeas { "${cluster_hostname}_internal_hosts":
        context => "/files/${dnsmasq_hosts_file}",
        incl => $dnsmasq_hosts_file,
        lens => 'Hosts.lns',
        changes => $cluster_login_nodes_host_entries_script,
        notify => Service['dnsmasq'],
    }

    augeas { "${cluster_hostname}_hosts":
        context => '/files/etc/hosts',
        incl => '/etc/hosts',
        lens => 'Hosts.lns',
        changes => $host_entries_on_login_node,
    }

# Tell nodes inside the cluster to use this node as a DNS server.

# Proxy HTTP and HTTPS for the internal network.
    class { 'hpc_cluster::login_node::proxy':
        internal_ipv4_subnet => $internal_ipv4_subnet,
    }

# Configure the internal network interfaces.
    $augeas_ifcfg = '/files/etc/sysconfig/network-scripts/ifcfg'
    augeas { "${hostname} ${cluster_hostname} internal":
        context => "${augeas_ifcfg}-${internal_interface}",
        changes => [
            'set ONBOOT yes',
            'set BOOTPROTO static',
            "set IPADDR ${internal_ipv4_address}",
            'set NETMASK 255.255.0.0',
        ],
    }
    if $use_infiniband == 'true' {
# To drive the Infiniband card:
        package { ['rdma', 'ibutils', 'libibverbs']:
            ensure => present,
        }
        ->
        service { 'rdma':
            enable => true,
            ensure => running,
        }
        ->
# Set the InfiniBand network address. (This doesn't bring up the
# interface.)
        augeas { "${hostname} ${cluster_hostname} infiniband internal":
            context => "${augeas_ifcfg}-${infiniband_interface}",
            changes => [
                'set ONBOOT yes',
                'set BOOTPROTO static',
                "set IPADDR ${internal_infiniband_ipv4_address}",
                'set NETMASK 255.255.0.0',
                'set NM_CONTROLLED no',
                ],
        }
    }


# Prepare the /srv/passwd directory for the below.
    file { '/srv/passwd':
        ensure => directory,
        owner => root, group => 0, mode => 0644,
    }

# Pass user and group information to the inside of the cluster.
    file { '/etc/cron.hourly/hpc_cluster_passwd_group':
        owner => root, group => 0, mode => 0755,
        source => "puppet:///modules/hpc_cluster/gather.cron",
    }

# Export that information to the nodes inside the cluster.
    augeas { 'export_passwd_to_cluster':
        context => '/files/etc/exports',
        changes => [
            'rm dir[.="/srv/passwd"]',
            'set dir[999] "/srv/passwd"',
            "set dir[.='/srv/passwd']/client \
                    ${internal_ipv4_subnet}",
            'set dir[.="/srv/passwd"]/client/option ro',
        ],
    }
    include nfs
    class { 'nfs::allow':
        from => $internal_ipv4_with_netmask,
    }

# Tell nodes inside the cluster to grab this user and group
# information.
    @@automount::mount { 'passwd':
        from => "${cluster_hostname}:/srv/passwd",
        tag => "${cluster_hostname}_passwd",
    }

# Listen inside the cluster for SMTP mail to relay to the outside.
    include hpc_cluster::login_node::smtp

# Tell nodes inside the cluster to use the login node as proxy.
    @@proxy::yum { "${cluster_hostname}":
        host => 'login',
        port => 3128,
    }

# Tell nodes inside the cluster to use the login node as DNS server.
    @@augeas { "${cluster_hostname} dns":
        context => '/files/etc/resolv.conf',
        changes => [
            'rm *',
            "set nameserver ${login_internal_ipv4}",
            "set search/domain[1] ${cluster_fqdn}",
            "set search/domain[2] ${::domain}",
        ],
    }

# Tell nodes inside the cluster to use the login node as gateway.
    @@augeas { "${cluster_hostname} gateway":
        context => "${augeas_ifcfg}-eth0",
        changes => "set GATEWAY ${login_internal_ipv4}",
    }


# Install the Scyld OpenMPI packages. (Not automated yet.)
#
# We used to make sure the Scyld modulefiles were on the MODULEPATH
# with an extra \verb!profile.d! script. But now the
# \verb!shell::env_modules! class (\S\ref{class_shell::env_modules})
# takes a parameter we can set to include
# \verb!/opt/scyld/modulefiles!.
    file { '/etc/profile.d/before_modules_2.sh':
        ensure => absent,
    }

}
