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
# \subsection{STIG-required Samba configuration under Mac OS X}

class samba::stig::darwin {

# \implements{macosxstig}{GEN006100 M6,GEN006140 M6}%
# Control ownership and permissions of \verb!smb.conf!. 
    file { "/etc/smb.conf":
        owner => root, group => 0, mode => 0644,
    }

# \implements{macosxstig}{GEN006150 M6}%
# Remove extended ACLs on \verb!smb.conf!.
    no_ext_acl { "/etc/smb.conf": }
}
