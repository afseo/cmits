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
# \subsection{File and directory permissions relating to auditing}

class audit::file_permissions {

# First, establish what \emph{system audit logs} and \emph{audit tool
# executables} are.
    $audit_data = $::osfamily ? {
        'darwin' => '/var/audit',
        'redhat' => '/var/log/audit',
        default  => unimplemented,
    }
    $audit_tools = $::osfamily ? {
# This list of executables comes from the check content in the Mac OS X STIG.
        'darwin' => ['/usr/sbin/audit', '/usr/sbin/auditd',
                     '/usr/sbin/auditreduce',
                     '/usr/sbin/praudit'],
# This list of executables comes from \verb!rpm -ql audit!.
        'redhat' => ['/sbin/audispd', '/sbin/auditctl',
                     '/sbin/auditd', '/sbin/aureport',
                     '/sbin/ausearch', '/sbin/autrace',
                     '/usr/bin/aulast', '/usr/bin/aulastlog',
                     '/usr/bin/ausyscall'],
        default  => unimplemented,
    }

# \implements{iacontrol}{ECRR-1}%
# Let only admins access audit data.
#
    case $::osfamily {
        'RedHat': {
# \implements{unixsrg}{GEN002680,GEN002690,GEN002700}%
# Ensure proper ownership and permissions on audit logs.
            file { $audit_data:
                recurse => inf,
                owner => root, group => 0, mode => 0600,
            }
# \implements{unixsrg}{GEN002710}%
# Remove extended ACLs on audit logs.
            no_ext_acl { $audit_data: recurse => true }
        }
        'Darwin': {
            audit::darwin::permissions { $audit_data: }
        }
    }

# \implements{macosxstig}{GEN002710 M6}%

# \implements{unixsrg}{GEN002715,GEN002716,GEN002717}%
# Ensure proper ownership and permissions on audit tool executables.
#
# \implements{mlionstig}{OSX8-00-00400}%
# Make sure \verb!praudit! is the right binary.
# \implements{mlionstig}{OSX8-00-00405}%
# Make sure \verb!auditreduce! is the right binary.
# \implements{mlionstig}{OSX8-00-00410}%
# Make sure \verb!audit! is the right binary.
# \implements{mlionstig}{OSX8-00-00415}%
# Make sure \verb!auditd! is the right binary.
#
# These will be correct by default (RHEL5, RHEL6), so this is defense in depth.
#
# The OSX Mountain Lion STIG lists the exact checksums which the files
# must match, and this just makes sure the files don't change against
# the first time they are observed. But the checksums in the STIG are
# not the correct ones for Mavericks nor Snow Leopard anyway.

    file { $audit_tools:
        owner => root, group => 0,
        audit => all,
    }

# \implements{macosxstig}{GEN002718 M6}%
# \implements{unixsrg}{GEN002718}%
# Remove extended access control lists (ACLs) on audit tool executables.
    no_ext_acl { $audit_tools: }
}

