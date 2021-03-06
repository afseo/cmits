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
# \subsection{Notice of monitoring via SSH}
#
# \implements{unixsrg}{GEN005550} Configure sshd to show a login warning.

class dod_login_warnings::ssh {
    $banner_file = '/etc/issue.ssh'

    file { $banner_file:
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/dod_login_warnings/80col",
    }
    class { 'ssh::banner':
        file => $banner_file,
    }
}
