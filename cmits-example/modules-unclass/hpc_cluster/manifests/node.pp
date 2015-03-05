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
# \subsection{All internal nodes}
#
# Any node inside the cluster needs these resources. With cluster
# management software, perhaps only the management nodes will run
# Puppet, and will cause the compute nodes to fall in line by other
# means than Puppet.

class hpc_cluster::node($cluster_hostname) {
    Proxy::Yum <<| name == "${cluster_hostname}" |>>
    Augeas <<| name == "${cluster_hostname} dns" |>>
    Augeas <<| name == "${cluster_hostname} gateway" |>>
    Smtp::Use_smarthost <<| tag == $cluster_hostname |>>
    include ::ntp
    Augeas <<| name == "${cluster_hostname} ntp.conf" |>>

    package { [
            'lynx',
            'man',
            'vim-enhanced',
            'wget',
            'bind-utils',
            'ipmitool',
# panfs install uses bc.
            'bc',
# Infiniband.
            'opensm',
            'ibutils',
            'rdma',
            'libibverbs-utils',
            'infiniband-diags',
        ]:
            ensure => installed,
    }

    service {
        'rdma':
            enable => true,
            ensure => running;
        'opensm':
            enable => true,
            ensure => running;
    }

# This is so when people \verb!module add openmpi!, they will get the
# PGI version by default, from among the \verb!openmpi!s that Scyld
# has built.
    file { '/opt/scyld/modulefiles/openmpi/.modulerc':
        ensure => present,
        owner => root, group => 0, mode => 0644,
        content => "#%Module
module-version pgi default
",
    }

}
