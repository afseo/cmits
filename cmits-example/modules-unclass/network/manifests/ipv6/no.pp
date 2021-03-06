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
# \subsubsection{Turn off IPv6}
#
# Air Force TCNO 2008-011-301 requires disabling IPv6. The UNIX SRG requires
# disabling it ``unless needed.''

class network::ipv6::no {
    case $::osfamily {
        'redhat': { include network::ipv6::no::redhat }
        'darwin': { include network::ipv6::no::darwin }
        default:  { unimplemented() }
    }
}
