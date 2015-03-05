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
define automount::mount::darwin($under, $from, $ensure, $options) {
    case $::macosx_productversion_major {
        '10.6': {
            automount::mount::darwin_10_6 { $name:
                under => $under,
                from => $from,
                ensure => $ensure,
                options => $options,
            }
        }
        '10.9': {
            automount::mount::darwin_10_9 { $name:
                under => $under,
                from => $from,
                ensure => $ensure,
                options => $options,
            }
        }
    }
}
