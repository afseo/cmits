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
# \section{SSH}
#
# See~\S\ref{class_hpcmp::openssh} for other SSH client-side configuration
# which may apply to some hosts.

class ssh {
    $configdir = $::osfamily ? {
        'RedHat' => '/etc/ssh',
        'Darwin' => '/etc',
        default  => unimplemented(),
    }
    $server_config = "${configdir}/sshd_config"
    $client_config = "${configdir}/ssh_config"

    $service_name = $::osfamily ? {
        'redhat' => 'sshd',
        'darwin' => 'com.openssh.sshd',
        default  => unimplemented(),
    }

    service { 'sshd':
        name => $service_name,
    }
}
