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
# \subsection{Remove Samba}
#
# \implements{unixsrg}{GEN006060} Remove Samba ``unless needed.'' We do not
# need it here.
class samba::no {
    package {
        "samba-swat": ensure => absent;
        "samba": ensure => absent;
        "samba4": ensure => absent;
    }
}
