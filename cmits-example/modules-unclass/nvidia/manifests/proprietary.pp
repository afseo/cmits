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
# \subsection{Proprietary drivers}
#
# Install proprietary NVIDIA graphics drivers for best graphics performance.
# The original documentation for this process is the README for the NVIDIA
# driver.
#
# Assumptions that we are running Red Hat Enterprise Linux or a derivative are
# common in this class.
#
# The installer\_dir should be a directory that always exists, and contains at
# least two shell scripts \verb!latest-x86_64! and \verb!latest-i386!. Most
# likely it will be a directory containing a bunch of Linux NVIDIA driver
# installers, with one symlinked as \verb!latest-x86_64! and one symlinked as
# \verb!latest-i386!. For desktops this may be a networked directory; for
# laptops it should be a cached copy on the local hard drive, because if
# someone takes the laptop off the network, and a new kernel has been
# installed, but never yet booted, the video driver will need to be reinstalled
# without reference to the network.

class nvidia::proprietary($installer_dir) {

    if $::has_nvidia_graphics_card == 'true' {

# The NVIDIA driver must be installed when X is not running. Rather than figure
# out how to safely kill the X server and boot the console user off, we just
# install an init script that will install the driver at boot time.
#
# Nowadays, graphical boot is common because it looks slick, but for this
# purpose it gets in our way. Turn it off:
        include grub::rhgb::no

# The driver builds some adapter code, then links it with the proprietary
# driver code to arrive at a kernel module. To do this, it needs the C
# compiler, and the kernel development files.
        package { [
                'gcc',
                'kernel-devel',
            ]:
            ensure => present,
        }
        require common_packages::make

# Now install the init script.
        file { "/etc/rc.d/init.d/nvidia-rebuild":
            owner => root, group => 0, mode => 0755,
            content => template('nvidia/nvidia-rebuild.sh.erb'),
# If the X server is not installed before the proprietary NVIDIA driver, the
# driver won't install all of its files properly.
            require => Package['xorg-x11-server-Xorg'],
        }

# With the script installed the service can be added.
        exec { 'add_nvidia_rebuild_service':
            command => '/sbin/chkconfig --add nvidia-rebuild',
            refreshonly => true,
            subscribe => File['/etc/rc.d/init.d/nvidia-rebuild'],
        }

# The init script defines an \verb!nvidia-rebuild! service; enable it so it
# will be started at boot. We don't want to start it immediately: if this isn't
# boot time, there's most likely an X server running, so it would fail.
        service { 'nvidia-rebuild':
            enable => true,
            require => [
                File['/etc/rc.d/init.d/nvidia-rebuild'],
                Exec['add_nvidia_rebuild_service'],
            ],
        }

# Place an X configuration file so that X will use the nvidia driver. In order
# to allow further configuration, like TwinView or rotated displays, we won't
# replace the configuration if it's already there.
        file { '/etc/X11/xorg.conf.d/01-nvidia.conf':
            owner => root, group => 0, mode => 0644,
            replace => false,
            source => "puppet:///modules/nvidia/01-nvidia.conf",
# The xorg.conf.d directory is provided by this X server package. (And maybe
# others.)
            require => Class['xserver'],
        }

# The NVIDIA proprietary driver will not install if the Nouveau driver is in
# use. So to install the proprietary driver we must disable the Nouveau driver:
        if $::using_nouveau_driver == 'true' {

# Change the GRUB config to prevent the initrd from loading the Nouveau driver.
            include grub::nouveau::no

# Prevent the system after boot from automatically loading Nouveau.
            file { '/etc/modprobe.d/disable-nouveau.conf':
                owner => root, group => 0, mode => 0644,
                content => "blacklist nouveau\n\
options nouveau modeset=0\n",
            }
        }

# Let admins sudo to run the driver installer manually if need be.
        sudo::auditable::command_alias { 'NVIDIA_DRIVERS':
            type => 'exec',
            commands => [
                "${installer_dir}/NVIDIA*.run",
                ],
        }
    }
}

