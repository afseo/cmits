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
# \subsection{STIG-required screensaver configuration}
class gnome-screensaver::stig {
# All settings we are about to set should go in the mandatory GConf tree. And
# that is the default for this resource type.
    gconf {
# \bydefault{RHEL6}{unixsrg}{GEN000510} Make sure the screensaver will only
# show something publicly viewable, such as a blank screen. RHEL6 does not ship
# with any screensavers that could show anything not publicly viewable.
        "/apps/gnome-screensaver/mode":
            ensure => absent;
# \implements{unixsrg}{GEN000500}%
# Cause the screen to lock after 15 minutes of inactivity, requiring
# re-authen\-tic\-ation to unlock it.
        "/apps/gnome-screensaver/idle_activation_enabled":
            type => bool, value => true;
# \implements{rhel5stig}{GEN000500-3} Enable the lock setting of the screensaver.
        "/apps/gnome-screensaver/lock_enabled":
            type => bool, value => true;
# \implements{rhel5stig}{GEN000500-2} Set the screensaver idle delay to 15
# minutes.
        "/apps/gnome-screensaver/idle_delay":
            type => int, value => 15;
    }
}
