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
# \section{sudo}
#
# The parts of this module you want to use are \verb!sudo::allow_user!
# and \verb!sudo::allow_group!. See them below. Everything else is
# machinery to make them happen portably.

class sudo(
    $sudoers=$sudo::params::sudoers,
    $sudoers_d=$sudo::params::sudoers_d)
inherits sudo::params {

# As much as possible, we are writing each piece of sudo configuration
# in its own file. We place these files in the \verb!$sudoers_d!.
    file { $sudoers_d:
        ensure => directory,
        owner => root, group => 0, mode => 0750,
    }

    case $::osfamily {
# RHEL5 and RHEL6 both have sudo newer than 1.7.1, which is when the
# \verb!#includedir! directive was added. In these cases we can just
# \verb!#includedir! our \verb!sudoers.d! directory.
        'RedHat': {
            augeas { 'consult_sudoers_d':
                context => "/files${sudoers}",
                incl => $sudoers,
                lens => "Sudoers.lns",
                changes => "set '#includedir' '${sudoers_d}'",
            }
        }
# We deal with Snow Leopard in \verb!sudo::policy_file!.
        'Darwin': {}
        default: { unimplemented() }
    }
}
