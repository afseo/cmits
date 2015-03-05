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
# \subsection{Set login banner}
#
# Set a banner that will be seen by people who connect via SSH, before they
# authenticate.
#
# The \verb!file! parameter must be the absolute path of a file on the client
# host.

class ssh::banner($file) {
    include ssh

    augeas { "enable_ssh_banner":
        context => "/files${ssh::server_config}",
        changes => "set Banner /etc/issue.ssh",
        notify => Service[sshd]
    }
}
