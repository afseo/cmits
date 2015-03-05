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
# \subsection{Disable host-based authentication}

class stig_misc::host_based_authn {
# \implements{unixsrg}{GEN002040} Remove \verb!hosts.equiv! and
# \verb!shosts.equiv! files.
    file { "/etc/hosts.equiv": ensure => absent }
    file { "/etc/shosts.equiv": ensure => absent }
}
