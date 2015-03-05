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
# \subsection{STIG-required Samba configuration under Red Hat}

class samba::stig::redhat {

# \implements{unixsrg}{GEN006100,GEN006120,GEN006140}%
# Control ownership and permissions of \verb!smb.conf!. 
#
# Under RHEL, all Samba configuration goes under \verb!/etc/samba!, so we
# secure \verb!/etc/samba/smb.conf! not \verb!/etc/smb.conf!.
    file { "/etc/samba/smb.conf":
        owner => root, group => 0, mode => 0644,
    }

# \implements{unixsrg}{GEN006150}%
# Remove extended ACLs on \verb!smb.conf!.
    no_ext_acl { "/etc/samba/smb.conf": }

# \implements{unixsrg}{GEN006160,GEN006180,GEN006200}%
# Control ownership and permissions of \verb!smbpasswd!.
    file { "/etc/samba/smbpasswd":
        owner => root, group => 0, mode=> 0600,
    }

# \implements{unixsrg}{GEN006210}%
# Remove extended ACLs on \verb!smbpasswd!.
    no_ext_acl { "/etc/samba/smbpasswd": }

}
