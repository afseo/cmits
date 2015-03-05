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
# \subsection{Lock down essential network analysis tools}
#
# For network tools that can't or shouldn't be removed, lock down access to
# them.

class network_tools::stig_essential {
# \implements{macosxstig}{GEN003960 M6,GEN003980 M6,GEN004000 M6}%
# \implements{unixsrg}{GEN003960,GEN003980,GEN004000}%
# Make the {\tt traceroute} utility executable only by root.
    $traceroute = $::osfamily ? {
# We'll throw in \verb!traceroute6! for free.
        'redhat' => [ '/bin/traceroute', '/bin/traceroute6' ],
        'darwin' => '/usr/sbin/traceroute',
        default  => unimplemented,
    }
    file { $traceroute:
        owner => root, group => 0, mode => 0700;
    }
# \implements{macosxstig}{GEN004010 M6}%
# \implements{unixsrg}{GEN004010}%
# Remove extended ACLs on the {\tt traceroute} executable.
    no_ext_acl { $traceroute: }
}
