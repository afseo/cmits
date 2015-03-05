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
# \subsection{Turn off notifications}
#
# For users who somehow have the \verb!gpk-update-icon! running, turn off
# notifications to them about things which, after all, they can't control.

class packagekit::no_notify {
    Gconf {
        type => bool, value => false,
    }
    $agpui = "/apps/gnome-packagekit/update-icon"
    gconf {
        "$agpui/notify_update_failed":;
        "$agpui/notify_critical":;
        "$agpui/notify_available":;
        "$agpui/notify_distro_upgrades":;
        "$agpui/notify_complete":;
        "$agpui/notify_update_started":;
        "$agpui/notify_update_complete_restart":;
        "$agpui/notify_update_complete":;
        "$agpui/notify_message":;
        "$agpui/notify_errors":;
        "$agpui/notify_update_not_battery":;
    }
}
