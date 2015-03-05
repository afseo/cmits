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
# \subsection{Timeout}
#
# These settings will have the effect of kicking off clients who
# haven't sent data within the last ten minutes.

class ssh::timeout {
    include ssh
    augeas { "sshd_timeout":
        context => "/files${ssh::server_config}",
        changes => [
# \implements{mlionstig}{OSX8-00-00715}%
# Set the SSH server ClientAliveInterval to 600.
            'set ClientAliveInterval 600',
# \implements{mlionstig}{OSX8-00-00720}%
# Set the SSH server ClientAliveCountMax to 0.
            'set ClientAliveCountMax 0',
            ],
        notify => Service['sshd'],
    }
}
