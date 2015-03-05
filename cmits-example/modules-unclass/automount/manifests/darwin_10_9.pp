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
# \subsection{Automount configuration under Mavericks}

class automount::darwin_10_9 {
# To edit automount maps we need Augeas.
    require augeas

# Augeas 1.2.0 does not appear to understand how to edit
# \verb!/etc/auto_master! on a Mavericks Mac, even if it doesn't
# contain anything weird. Oh, well; what we need in it is quite fixed
# anyway.
    file { '/etc/auto_master':
        owner => root, group => 0, mode => 0644,
        content => "
/net auto_net
",
    }

# Make sure the auto.net file exists: otherwise any attempt at editing it will
# fail, causing errors.
    file { "/etc/auto_net":
        owner => root, group => 0, mode => 0644,
        ensure => present,
    }

    augeas { "automount_remove_autonet_script":
        require => File["/etc/auto_net"],
        context => "/files/etc/auto_net",
        changes => "rm script_content",
    }
}
