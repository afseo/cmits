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
# \subsection{STIG-required shell configuration}

class shell::stig {
    File {
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }
# \implements{unixsrg}{GEN001780}%
# Don't let users \verb!write! each other, because ``messaging can be used to
# cause a denial-of-service attack.''
    file { "/etc/profile.d/mesg.sh":
        content => "mesg n\n",
    }
    file { "/etc/profile.d/mesg.csh":
        content => "mesg n\n",
    }

# \implements{unixsrg}{GEN002120}%
# Make sure the \verb!/etc/shells! file exists and has controlled contents.
#
# The contents are specified here, because the ensuing requirements apply to
# each shell. If you add a shell to the contents of \verb!/etc/shells! here,
# you must add corresponding policy below.
    $valid_shells = $::osfamily ? {
        'redhat' => "/bin/sh
/bin/bash
/sbin/nologin
/bin/tcsh
/bin/csh
/bin/zsh
",
        'darwin' => "/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
",
        default  => unimplemented,
    }
    file { "/etc/shells":
        ensure => present,
        owner => root, group => 0, mode => 0644,
        content => $valid_shells,
    }

# \implements{unixsrg}{GEN002140}%
# Make sure that all shells listed in \verb!/etc/passwd! are listed in
# \verb!/etc/shells!.
#
# (This script will change any which are not listed to \verb!/sbin/nologin!.)
    cron::daily { 'valid-shells':
        source => "puppet:///modules/shell/valid-shells",
    }


# \implements{macosxstig}{GEN002200 M6,GEN002220 M6}%
# \implements{unixsrg}{GEN002200,GEN002210,GEN002220}%
# Control ownership and permissions of shell executables.
#
# The STIGs say 0755, but we use 0555 here; it is more restrictive and
# comports with default Mac configuration.
    file {
        "/bin/sh": owner => root, group => 0, mode => 0555;
        "/bin/bash": owner => root, group => 0, mode => 0555;
        "/sbin/nologin": owner => root, group => 0, mode => 0555;
        "/bin/tcsh": owner => root, group => 0, mode => 0555;
        "/bin/csh": owner => root, group => 0, mode => 0555;
        "/bin/ksh": owner => root, group => 0, mode => 0555;
        "/bin/zsh": owner => root, group => 0, mode => 0555;
    }
# \implements{macosxstig}{GEN002230 M6}%
# \implements{unixsrg}{GEN002230}%
# Remove extended ACLs on shell executables.
    no_ext_acl {
        "/bin/sh":;
        "/bin/bash":;
        "/sbin/nologin":;
        "/bin/tcsh":;
        "/bin/csh":;
        "/bin/ksh":;
        "/bin/zsh":;
    }

    include shell::global_init_files
}
