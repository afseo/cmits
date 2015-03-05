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
# \subsubsection{Setting the GDM logo under RHEL5}

class gdm::logo::rhel5($source) {
    $hic = "/usr/share/icons/hicolor"
    file {
        "$hic/48x48/stock/image/puppet-logo.png":
            owner => root, group => 0, mode => 0644,
            source => "${source}/logo-48x48.png";
        "$hic/scalable/stock/image/puppet-logo.png":
            owner => root, group => 0, mode => 0644,
            source => "${source}/logo-scalable.png";
    }

    $logo = "${hic}/scalable/stock/image/puppet-logo.png"

    require augeas
    augeas { 'gdm_logo':
        context => '/files/etc/gdm/custom.conf',
        changes => [
            'set daemon/Greeter /usr/libexec/gdmlogin',
            'set greeter/DefaultWelcome false',
# Don't ``welcome'' the user: legalities.
            'set greeter/Welcome "%n"',
            "set greeter/Logo ${logo}",
            ],
    }
}
