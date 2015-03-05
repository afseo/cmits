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
# \subsection{Disable xinetd}
#
# \implements{unixsrg}{GEN003700}%
# Disable \verb!xinetd! if no services it provides are enabled.
#
# Note that the SRG does not say that \verb!xinetd! must always be disabled or
# uninstalled: but we aren't using it on any hosts controlled by this policy
# yet, so might as well uninstall it.

class stig_misc::xinetd {
    package { "xinetd": ensure => absent }
 #    service { "xinetd":
 #        ensure => stopped,
 #        enable => false,
 #    }
# Other packages may install files into \verb!/etc/xinetd.d! so even if
# \verb!xinetd! is not installed we still need to ensure ownership and
# permissions. Note that if we start using xinetd, we'll have to secure the
# \verb!xinetd.conf! file in addition to what's below.
#
# \implements{unixsrg}{GEN003720,GEN003730,GEN003740,GEN003750}%
# Control ownership and permissions of the \verb!xinetd! configuration.
    file { "/etc/xinetd.d":
        owner => root, group => 0, mode => 0440,
    }
# \implements{unixsrg}{GEN003745,GEN003755}%
# Remove extended ACLs on \verb!xinetd! configuration.
    no_ext_acl { "/etc/xinetd.d": }

# \notapplicable{unixsrg}{GEN003800}%
# If we remove xinetd, it doesn't matter whether it logs or traces because it
# doesn't do anything.

}

