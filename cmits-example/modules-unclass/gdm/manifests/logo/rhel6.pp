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
# \subsubsection{Setting the GDM logo under RHEL6}

class gdm::logo::rhel6($source) {
    $agsg = '/apps/gdm/simple-greeter'
    gconf { "$agsg/logo_icon_name":
        config_source => '/var/lib/gdm/.gconf',
        type => string,
        value => 'puppet-logo',
    }

    $hic = "/usr/share/icons/hicolor"
    file {
        "$hic/48x48/stock/image/puppet-logo.png":
            owner => root, group => 0, mode => 0644,
            source => "${source}/logo-48x48.png",
            notify => Exec['gdm_logo_update_icon_cache'];
        "$hic/scalable/stock/image/puppet-logo.png":
            owner => root, group => 0, mode => 0644,
            source => "${source}/logo-scalable.png",
            notify => Exec['gdm_logo_update_icon_cache'];
    }

    exec { 'gdm_logo_update_icon_cache':
        command => "/usr/bin/gtk-update-icon-cache $hic",
        refreshonly => true,
    }

}
