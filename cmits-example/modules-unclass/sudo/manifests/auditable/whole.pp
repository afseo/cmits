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
class sudo::auditable::whole(
    $sudoers=$sudo::params::sudoers,
    $sudoers_d=$sudo::params::sudoers_d,
    ) inherits sudo::params {
# It may be possible to use augeas instead of datacat, but as of May
# 2014 the Augeas sudoers lens couldn't seem to deal with aliases
# having items starting with bangs (\verb+!+), which would prevent us
# from disallowing anything. Whitelisting each possible binary by name
# would be a sad business.
    datacat { "sudoers.d/90auditable_whole":
        path => "${sudoers_d}/90auditable_whole",
        template => "${module_name}/auditable/whole.erb",
        owner => root, group => 0, mode => 0440,
    } ->
    sudo::include_policy_file { "90auditable_whole":
        sudoers => $sudoers,
        sudoers_d => $sudoers_d,
    }
}
