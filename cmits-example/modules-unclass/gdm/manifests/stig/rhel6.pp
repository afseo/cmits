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
# \subsubsection{Under RHEL6}
#
# \unimplemented{rhel5stig}{GEN000000-LNX00360,GEN000000-LNX00380}{GDM X server
# startup requirements appear to be unimplementable under RHEL6.}
#
# RHEL 6 contains \verb!gdm! 2.30. At \verb!2.22!, GDM was rewritten, and no
# longer pays attention to the server-startup-related sections of
# \verb!/etc/gdm/custom.conf!. See
# \url{https://bugzilla.redhat.com/show_bug.cgi?id=452528},
# \url{http://live.gnome.org/GDM/2.22/Configuration}. It appears that the
# command-line switches \verb!-br -verbose! are hard-coded into
# \verb!/usr/libexec/gdm-simple-slave!.
#
# I have filed RHBZ 773111 about this.
# \url{https://bugzilla.redhat.com/show_bug.cgi?id=773111}

class gdm::stig::rhel6 {}

