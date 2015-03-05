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
# \subsection{Remove network analysis tools}
#
# \implements{unixsrg}{GEN003865} Remove tools used for packet capture and
# analysis.
class stig_misc::network_tools {
    package {
        "iptraf": ensure => absent;
        "mtr-gtk": ensure => absent;
        "mtr": ensure => absent, require => Package['mtr-gtk'];
        "nmap": ensure => absent;
        "wireshark-gnome": ensure => absent;
        "wireshark": ensure => absent, require => Package['wireshark-gnome'];
# This one may be innocuous---but once I had it installed and it made a log
# message about root logging in, \emph{every five seconds}. Kill it with fire!
        "mrtg": ensure => absent;
        "tcpdump": ensure => absent;
    }

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
