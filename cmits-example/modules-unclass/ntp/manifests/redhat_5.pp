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
class ntp::redhat_5 {
    package { 'ntp':
        ensure => present,
    }
    service { 'ntpd':
        enable => true,
        ensure => running,
    }

# \implements{unixsrg}{GEN000250,GEN000251,GEN000252} Control ownership and
# permissions of the \verb!ntp.conf! file.
    file { "/etc/ntp.conf":
        owner => root, group => 0, mode => 0640,
    }
# \implements{unixsrg}{GEN000253} Remove extended ACLs on the \verb!ntp.conf!
# file.
    no_ext_acl { "/etc/ntp.conf": }
}
