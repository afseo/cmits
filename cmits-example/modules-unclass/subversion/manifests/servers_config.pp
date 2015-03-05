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
# \subsection{Prepare to edit the systemwide Subversion server configuration file}

class subversion::servers_config {
    file { '/etc/subversion':
        ensure => directory,
        owner => root, group => 0, mode => 0755,
    }

    file { '/etc/subversion/servers':
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }

# We require a custom lens because Augeas doesn't ship with one for Subversion.
    include augeas
}
