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
# \subsection{Where root can log in}
#
# \implements{unixsrg}{GEN000980,GEN001020} Make sure root can only log in from
# the console.
#
# ``Console'' means any tty listed in \verb!/etc/securetty!. It's likely that
# some setting in \verb!/etc/login.defs! could be set to ensure this property;
# but we can be more general by using PAM to enforce it instead.
class root::login {
    case $::osfamily {
        'RedHat': {
            include pam::securetty

# Make sure the \verb!/etc/securetty! file contains exactly what it should.
#
# \implements{rhel5stig}{GEN000000-LNX00620,GEN000000-LNX00640,GEN000000-LNX00660}%
# Control ownership and permissions on the \verb!securetty! file.
            file { "/etc/securetty":
                owner => root, group => 0, mode => 0600,
                source => "puppet:///modules/root/login/securetty",
            }
# Interestingly, there appears to be no STIG requirement to remove extended
# ACLs from this file. But we do it anyway.
            no_ext_acl { "/etc/securetty": }
        }
# Mac OS X doesn't support root logins at all by default.
        'Darwin': {}
        default: { unimplemented() }
    }
}
