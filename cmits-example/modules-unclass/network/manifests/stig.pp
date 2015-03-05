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
# \subsection{STIG-required network configuration}

class network::stig {
# \subsubsection{Common implementations of compliance}
#
# \implements{macosxstig}{GEN003760 M6,GEN003770 M6,GEN003780 M6}%
# \implements{unixsrg}{GEN003760,GEN003770,GEN003780}%
# Control ownership and permissions of the \verb!services! file.
    file { "/etc/services":
        owner => root, group => 0, mode => 0644,
    }
# \implements{unixsrg}{GEN003790}%
# Remove extended ACLs on the \verb!services!  file.
    no_ext_acl { "/etc/services": }

# \subsubsection{Platform-specific implementations of compliance}
    case $::osfamily {
        'RedHat': { include network::stig::redhat }
        'Darwin': { include network::stig::darwin }
        default:  { unimplemented() }
    }
}
