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
# \subsection{Remove package update icon}
#
# Users can't usefully install package updates. Don't bother showing them the
# icon.
class packagekit::no_icon {

# This works for RHEL6.
    file { "/etc/xdg/autostart/gpk-update-icon.desktop":
        ensure => absent,
    }

# This works for RHEL5.
    file { "/etc/xdg/autostart/puplet.desktop":
        ensure => absent,
    }
}
