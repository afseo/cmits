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
# \subsection{STIG-required NFS configuration}
class nfs::stig {
    include nfs
# \implements{unixsrg}{GEN005740,GEN005750,GEN005760}%
# Control ownership and permissions of the \verb!exports! file.
    file { "/etc/exports":
        owner => root, group => 0, mode => 0644,
    }
# \implements{unixsrg}{GEN005770}%
# Remove extended ACLs on the \verb!exports!  file.
    no_ext_acl { "/etc/exports": }
# \implements{rhel5stig}{GEN000000-LNX00560}%
# Remove the insecure\_locks export option wherever it exists.
    augeas { 'remove_insecure_locks_in_exports':
        context => '/files/etc/exports',
        changes => 'rm dir/client/option[.="insecure_locks"]',
    }
}
