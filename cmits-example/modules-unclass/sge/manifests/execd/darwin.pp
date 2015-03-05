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
class sge::execd::darwin($sge_root, $cluster_name) {

    mac_launchd_file { 'net.sunsource.gridengine.sgeexecd':
        description => "The GridEngine execute daemon \
runs jobs submitted by users to GridEngine.",
        environment => {
            'SGE_ROOT'          => $sge_root,
            'SGE_CELL'          => 'default',
            'SGE_ND'            => 1,
            'DYLD_LIBRARY_PATH' => "$sge_root/lib/darwin-x86",
        },
        arguments => ["$sge_root/bin/darwin-x86/sge_execd"],
    }

    service { 'net.sunsource.gridengine.sgeexecd':
        enable => true,
        ensure => running,
        require => Mac_launchd_file['net.sunsource.gridengine.sgeexecd'],
        subscribe => Mac_launchd_file['net.sunsource.gridengine.sgeexecd'],
    }

    include shell::profile_d
    file { '/etc/profile.d/sge.sh':
        owner => root, group => 0, mode => 0644,
        content => "
export SGE_ROOT=${sge_root}
export SGE_CLUSTER_NAME=${cluster_name}
export PATH=\$SGE_ROOT/bin/darwin-x86:\$PATH
export DYLD_LIBRARY_PATH=\$SGE_ROOT/lib/darwin-x86\${DYLD_LIBRARY_PATH:+:\$DYLD_LIBRARY_PATH}
export MANPATH=\$MANPATH:\$SGE_ROOT/man
",
    }
}
