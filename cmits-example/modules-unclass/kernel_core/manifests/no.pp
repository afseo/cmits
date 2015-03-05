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
# \subsection{Disable kernel dumping}
#
# \implements{macosxstig}{GEN003510 M6}%
# \implements{mlionstig}{OSX8-00-01105}%
# \implements{unixsrg}{GEN003510}%
# \implements{iacontrol}{DCSS-1}%
# \notapplicable{unixsrg}{GEN003520,GEN003521,GEN003522,GEN003523}%
# Disable kernel core dumping to improve the security of the system during
# aborts: Kernel core dump files will contain sensitive data, and heretofore we
# have not needed to debug crashed kernels.

class kernel_core::no {
    case $::osfamily {
        'redhat': {
            service { 'kdump': 
                enable => false,
                ensure => stopped,
            }
        }
        'darwin': {
            augeas { 'sysctl_kern_coredump_off':
                context => '/files/etc/sysctl.conf',
                changes => 'set kern.coredump 0',
            }
        }
        default:  { unimplemented() }
    }
}
