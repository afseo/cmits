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
# \subsection{Including policy files}
#
# RHEL 6 has sudo 1.8, which supports \verb!#includedir!. To make sudo
# pay attention to a new file in the \verb!sudoers.d! directory, we
# need do nothing. But Snow Leopard only has sudo 1.7.0, so we must
# \verb!#include! each sudo policy file.
#
# This defined resource type does whatever is necessary to make sudo
# pay attention to a file we've placed in the \verb!sudoers.d!.

define sudo::include_policy_file($ensure='present', $sudoers='', $sudoers_d='') {
    require sudo
    include sudo::params

    $d_sudoers = $sudoers ? {
        ''      => $sudo::params::sudoers,
        default => $sudoers,
    }
    $d_sudoers_d = $sudoers_d ? {
        ''      => $sudo::params::sudoers_d,
        default => $sudoers_d,
    }

    case $ensure {
        'absent': {
            case $osfamily {
                'RedHat': {}
                'Darwin': {
                    augeas { "sudoers_exclude_${name}":
                        context => "/files/${d_sudoers}",
                        incl => "${d_sudoers}",
                        lens => 'Sudoers.lns',
                        changes => [
                            "rm #include[.='${d_sudoers_d}/${name}']",
                            ],
                    }
                }
                default: { unimplemented() }
            }
        }
        default: {
            case $osfamily {
                'RedHat': {}
                'Darwin': {
                    augeas { "sudoers_include_${name}":
                        context => "/files/${d_sudoers}",
                        incl => "${d_sudoers}",
                        lens => 'Sudoers.lns',
                        changes => [
                            "set #include[last()+1] '${d_sudoers_d}/${name}'",
                            ],
                        onlyif => "match \
                            #include[.='${d_sudoers_d}/${name}'] size == 0",
                    }
                }
                default: { unimplemented() }
            }
        }
    }
}
