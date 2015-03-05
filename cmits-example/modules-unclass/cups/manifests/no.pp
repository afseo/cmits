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
# \subsection{Disable CUPS}
#
# \implements{unixsrg}{GEN003900}%
# On hosts which do not need to print, disable CUPS entirely. This trivially
# complies with this requirement not to ``allow all hosts to use local print
# resources.''
#

class cups::no {

# \implements{unixsrg}{GEN003920,GEN003930,GEN003940,GEN003950}%
# Remove CUPS and the ``hosts.lpd (or equivalent) file,'' which in the case of
# CUPS is \verb!/etc/cups/cupsd.conf!. This trivially prevents ``unauthorized
# modifications'' or ``unauthorized remote access.''

    include "cups::no::${::osfamily}"
    file { '/etc/cups/cupsd.conf':
        ensure => absent,
    }
}
