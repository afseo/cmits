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
# \subsection{STIG-required printing configuration}
#
# The SRG requirements pertain to the \verb!hosts.lpd! file. CUPS does not use
# such a file. The means by which the administrator tells CUPS from what hosts
# to accept print jobs is the file \verb!/etc/cups/cupsd.conf!.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN003900}%
# Under RHEL, the Common UNIX Printing System (CUPS) is configured by default
# only to listen to \verb!localhost!.

class cups::stig {

# First, make sure CUPS is installed and running.
    include "cups::${::osfamily}"

# \implements{unixsrg}{GEN003920,GEN003930,GEN003940}%
# Control ownership and permissions of the ``hosts.lpd (or equivalent) file,''
# in our case \verb!cupsd.conf!.
#
# (This file has mode \verb!0640! by default, which is less permissive than the
# required \verb!0664!.)
    file { "/etc/cups/cupsd.conf":
        owner => root, group => 0, mode => 0640,
    }
# \implements{unixsrg}{GEN003950}%
# Remove extended ACLs on the same file.
    no_ext_acl { "/etc/cups/cupsd.conf": }
}
