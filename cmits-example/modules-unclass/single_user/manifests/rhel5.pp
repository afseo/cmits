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
# \subsection{Securing single-user mode under RHEL5}
#
# \implements{unixsrg}{GEN000020} Require authentication for access to
# single-user mode.

class single_user::rhel5 {

# \implements{unixsrg}{GEN000020} Require authentication for access to
# single-user mode.
    augeas { "single_user":
        context => "/files/etc/inittab",
        changes => [
            "set ~/runlevels S",
            "set ~/action wait",
            "set ~/process /sbin/sulogin",
        ],
    }

# Also disallow hotkey interactive startup, where the user at the console gets
# to say which services start or not.
    augeas { "single_user_stepwise_init":
        context => "/files/etc/sysconfig/init",
        changes => "set PROMPT no",
    }

}
