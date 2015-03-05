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
# \subsection{Automount configuration under Red Hat}

class automount::redhat {
# To edit automount maps we need Augeas.
    require augeas

    package { "autofs": ensure => present}

    augeas { "automount_fixed_net_map":
        context => "/files/etc/auto.master",
        changes => [
            "set map[.='/net'] /net",
            "set map[.='/net']/name /etc/auto.net",
            "set map[.='/net']/options --ghost",
            "rm include",
            "rm map[.='/misc']",
        ],
    }

# Make sure the auto.net file exists: otherwise any attempt at editing it will
# fail, causing errors.
    file { "/etc/auto.net":
        owner => root, group => 0, mode => 0644,
        ensure => present,
    }

    augeas { "automount_remove_autonet_script":
        require => File["/etc/auto.net"],
        context => "/files/etc/auto.net",
        changes => "rm script_content",
    }

    service { "autofs":
        enable => true,
        ensure => running,
        require => Package["autofs"],
# For some reason some NFS mounts added did not show up when \verb!autofs! was
# restarted using the \verb!reload! verb instead of \verb!restart!. So even
# though \verb!restart! is slower and could screw more things up, it's what we
# need to use.
        restart => "/sbin/service autofs restart",
    }
}
