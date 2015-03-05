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
# \subsection{profile.d permissions}
#
# Set permissions for ``global initialization files'' according to the UNIX
# SRG.

class shell::global_init_files {

# \implements{unixsrg}{GEN001720,GEN001740,GEN001760}%
# \implements{macosxstig}{GEN001720 M6,GEN001740 M6,GEN001760 M6}%
# Make sure that no one can influence the environment variables set when the
# shell starts, except for root.
#
# On the Mac, \verb!/etc/profile.d! is not a usual place for global
# initialization files, but we put it there.
    $glif_owner = $::osfamily ? {
        'redhat'  => bin,
        'darwin'  => root,
        default => root,
    }
    File {
        owner => $glif_owner,
        group => 0,
        mode => 0444,
    }
    file {
        "/etc/profile.d":
            ensure => directory,
            recurse => true, recurselimit => 2;
        "/etc/profile": ensure => present;
        "/etc/bashrc":;
        "/etc/csh.login":;
        "/etc/csh.logout":;
        "/etc/csh.cshrc":;
    }

# \implements{unixsrg}{GEN001730}%
#
# Remove extended ACLs on shell startup files.
    no_ext_acl {
        "/etc/profile.d": recurse => true;
        "/etc/profile":;
        "/etc/bashrc":;
        "/etc/csh.login":;
        "/etc/csh.logout":;
        "/etc/csh.cshrc":;
    }
}
