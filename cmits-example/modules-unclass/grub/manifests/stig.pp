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
# \subsection{STIG-required configuration}

class grub::stig {
# \implements{rhel5stig}{GEN000000-LNX00720} Turn on auditing in time to audit the
# actions of startup scripts.
    $g = "/boot/grub/grub.conf"
    exec { "auditify_kernel_cmdlines":
        path => "/bin:/sbin",
        onlyif => "grep '^[[:space:]]*kernel' $g | \
                   grep -v audit=1 >&/dev/null",
        command => "sed -i.audit -e \
            '/[[:space:]]*kernel/s/\$/ audit=1/' $g",
        logoutput => true,
    }
# \doneby{admins}{unixsrg}{GEN008720,GEN008740,GEN008760,GEN008780}%
# Make sure the configuration file \verb!/boot/grub/menu.lst! is owned
# by root, group-owned by root, has permissions \verb!0600!, and has no
# extended ACL.
    file { $g:
        owner => root, group => 0, mode => 0600,
    }
    no_ext_acl { $g: }
}
