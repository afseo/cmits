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
# \subsection{STIG-required at subsystem configuration for RHEL}
#
# Under RHEL and derivatives, only allow root to do at jobs.

class at::stig::redhat {
    file {
# \implements{unixsrg}{GEN003252,GEN003300,GEN003480,GEN003490}%
# Remove \verb!at.deny!, in order to specify
# access by who is allowed, not by who is denied.
        "/etc/at.deny":
            ensure => absent;
# \implements{unixsrg}{GEN003280,GEN003320,GEN003460,GEN003470,GEN003340}%
# Control contents and permissions of \verb!at.allow!.
        "/etc/at.allow":
            owner => root, group => 0, mode => 0600,
            content => "root\n";
# \implements{unixsrg}{GEN003400,GEN003420,GEN003430}%
# Control permissions of ``the `at' directory.''
#
# In the default install, this is owned by \verb!daemon!, group \verb!daemon!,
# so this change might break \verb!at!. 
        "/var/spool/at":
            owner => root, group => 0, mode => 0700;
    }

    no_ext_acl {
# \implements{unixsrg}{GEN003245}%
# Remove extended ACL on \verb!at.allow!.
        "/etc/at.allow":;
# \implements{unixsrg}{GEN003255}%
# Remove extended ACL on \verb!at.deny!.
        "/etc/at.deny":;
# \implements{unixsrg}{GEN003410}%
# Remove extended ACLs in ``the `at' directory.''
        "/var/spool/at": recurse => true;
    }
}
#

