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
class network_tools::remove {
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
}
