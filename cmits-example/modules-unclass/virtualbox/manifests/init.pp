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
# \section{VirtualBox}
#
# VirtualBox stuff

class virtualbox {
	package {
		'VirtualBox-4.2.x86_64':
		ensure => present
}

# Let admins sudo to run the driver installer manually if need be.
        sudo::auditable::command_alias { 'VIRTUALBOX_DRIVERS':
            type => 'exec',
            commands => [
                "/etc/init.d/vboxdrv setup",
                ],
        }
}
