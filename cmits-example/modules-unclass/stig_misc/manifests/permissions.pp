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
# \subsection{Miscellaneous STIG-required file permission policies}
#
# Set sane permissions in various parts of the system which don't need
# configuration otherwise.
class stig_misc::permissions {
# \implements{macosxstig}{GEN001362 M6,GEN001363 M6,GEN001364 M6}%
# \implements{unixsrg}{GEN001362,GEN001363,GEN001364} Control ownership and
# permissions of \verb!resolv.conf!.
    file { "/etc/resolv.conf":
        owner => root, group => 0, mode => 0644,
    }
# \implements{macosxstig}{GEN001365 M6}%
# \implements{unixsrg}{GEN001365}%
# Remove extended ACLs on \verb!resolv.conf!.
    no_ext_acl { "/etc/resolv.conf": }

# \implements{macosxstig}{GEN001366 M6,GEN001367 M6,GEN001368 M6}%
# \implements{unixsrg}{GEN001366,GEN001367,GEN001368}%
# Control ownership and permissions of the \verb!hosts! file.
    file { "/etc/hosts":
        owner => root, group => 0, mode => 0644,
    }
# \implements{macosxstig}{GEN001369 M6}%
# \implements{unixsrg}{GEN001369}%
# Remove extended ACLs on the \verb!hosts! file.
    no_ext_acl { "/etc/hosts": }

# \implements{unixsrg}{GEN001371,GEN001372,GEN001373} Control ownership and
# permissions of \verb!nsswitch.conf!.
    file { "/etc/nsswitch.conf":
        owner => root, group => 0, mode => 0644,
    }
# \implements{unixsrg}{GEN001374} Remove extended ACLs on \verb!nsswitch.conf!.
    no_ext_acl { "/etc/nsswitch.conf": }

# \implements{macosxstig}{GEN001378 M6,GEN001379 M6,GEN001380 M6}%
# \implements{unixsrg}{GEN001378,GEN001379,GEN001380}%
# Control ownership and permissions of the \verb!passwd! file.
    file { "/etc/passwd":
        owner => root, group => 0, mode => 0644,
    }
# \implements{macosxstig}{GEN001390 M6}%
# \implements{unixsrg}{GEN001390} Remove extended ACLs on the \verb!passwd! file.
    no_ext_acl { "/etc/passwd": }

# \implements{macosxstig}{GEN001391 M6,GEN001392 M6,GEN001393 M6}%
# \implements{unixsrg}{GEN001391,GEN001392,GEN001393}%
# Control ownership and permissions of the \verb!group! file.
    file { "/etc/group":
        owner => root, group => 0, mode => 0644,
    }
# \implements{macosxstig}{GEN001394 M6}%
# \implements{unixsrg}{GEN001394}%
# Remove extended ACLs on the \verb!group! file.
    no_ext_acl { "/etc/group": }

# \implements{unixsrg}{GEN001400,GEN001410,GEN001420}%
# Control ownership and permissions of the \verb!shadow! file.
    file { "/etc/shadow":
        owner => root, group => 0, mode => 0400,
    }
# \implements{unixsrg}{GEN001430}%
# Remove extended ACLs on the \verb!shadow! file.
    no_ext_acl { "/etc/shadow": }

# \implements{unixsrg}{GEN002330}%
# Remove extended ACLs on sound device files.
    no_ext_acl {
        "/dev/dsp":;
        "/dev/audio":;
        "/dev/mixer":;
        "/dev/sequencer":;
        "/dev/snd": recurse => true;
    }

# \implements{macosxstig}{GEN002280 M6}%
# Make sure unprivileged users cannot remove devices. Device file permissions
# are ``as configured by the vendor:'' only ``device files specifically
# intended to be world-writable'' are world-writable.
    file { '/dev':
        owner => root, group => 0, mode => o-w,
    }

# \implements{rhel5stig}{GEN000000-LNX001431,GEN000000-LNX001432,GEN000000-LNX001433}%
    file { "/etc/gshadow":
        owner => root, group => 0, mode => 0400,
    }
# \implements{rhel5stig}{GEN000000-LNX001434}%
    no_ext_acl { "/etc/gshadow": }

# \implements{rhel5stig}{GEN000000-LNX00400,GEN000000-LNX00420,GEN000000-LNX00440}%
    file { "/etc/security/access.conf":
        owner => root, group => 0, mode => 0640,
    }
# \implements{rhel5stig}{GEN000000-LNX00450}%
    no_ext_acl { "/etc/security/access.conf": }

}
