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
define sudo::policy_file($content='', $ensure='present', $sudoers='', $sudoers_d='') {
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

    sudo::include_policy_file { $name:
        ensure => $ensure,
        sudoers => $d_sudoers,
        sudoers_d => $d_sudoers_d,
    }

    file { "${d_sudoers_d}/${name}":
        ensure => $ensure,
        owner => root, group => 0, mode => 0440,
        content => $content,
    }

# When placing a new file, we should make sure the file is in place
# before telling sudo to include it. When removing a file, we must
# make sure sudo isn't including it before we remove the file. This is
# because Snow Leopard's \verb!sudo! segfaults if anything is wrong
# with its configuration as a whole, with the ... undesirable result
# that no one can sudo to do anything.

    case $ensure {
        'present': {
            File["${d_sudoers_d}/${name}"] ->
            Sudo::Include_policy_file[$name]
        }
        default: {
            Sudo::Include_policy_file["$name"] ->
            File["${d_sudoers_d}/${name}"]
        }
    }
}
