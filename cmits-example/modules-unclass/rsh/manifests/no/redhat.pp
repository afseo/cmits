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
# \subsubsection{Disable rsh, rlogin, and rexec under Red Hat}

class rsh::no::redhat {
# \implements{unixsrg}{GEN003820,GEN003825,GEN003830,GEN003835,GEN003840,GEN003845}%
# Under RHEL, to ensure that rsh and rlogin are disabled, uninstall them.
#
# (Under RHEL, \verb!rsh!, \verb!rlogin!, \verb!rexec! and \verb!rcp! and their
# respective servers all come in two packages.)
    package {
        "rsh": ensure => absent;
        "rsh-server": ensure => absent;
    }
}
