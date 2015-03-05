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
define sudo::auditable::for(
    $run_as='ALL',
    $no_password=true,
) {
    $user_spec = $name
    $modifiers = $no_password ? {
        true    => 'NOPASSWD:',
        default => '',
    }
    $safe_userspec =     regsubst($user_spec, '[^a-zA-Z_]', '_')
    require sudo::auditable::whole
    sudo::policy_file { "99${safe_userspec}":
        ensure => present,
        content => template("${module_name}/auditable/rule.erb"),
    }
    sudo::remove_direct_sudoers_policy { "${name}": }
}
