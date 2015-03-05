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
class umask::stig::darwin {
# \implements{mlionstig}{OSX8-00-01015}%
# Set the default global umask setting for user applications to 027.
    file { '/etc/launchd-user.conf':
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }
    umask::set_in_file { '/etc/launchd-user.conf':
        umask => 027,
    }
# \implements{mlionstig}{OSX8-00-01020}%
# Set the default global umask setting for system processes to 022.
    file { '/etc/launchd.conf':
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }
    umask::set_in_file { '/etc/launchd.conf':
        umask => 022,
    }
}
