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
# This is used only by automount::mount::redhat.

define automount::mount::redhat::subdir($ensure='present') {
    include automount

# First, make sure we don't tread on existing configuration.
    if $name == 'net' {
        fail('You cannot use automount::subdir to create /net/net')
    }

# Now, make a subtable in the automount configuration.
    file { "/etc/auto.${name}":
        owner => root, group => 0, mode => 0644,
        ensure => $ensure,
    }
    if $ensure == 'present' {
        augeas { "automount_add_master_subdir_${name}":
            context => '/files/etc/auto.master',
            changes => [
                "set map[.='/net/${name}'] /net/${name}",
                "set map[.='/net/${name}']/name /etc/auto.${name}",
                "set map[.='/net/${name}']/options --ghost",
                ],
            require => [],
        }
    } else {
        unimplemented()
    }
}
