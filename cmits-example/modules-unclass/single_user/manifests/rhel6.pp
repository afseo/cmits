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
# \subsection{Securing single-user mode under RHEL6}
#
# RHEL6 uses Upstart as its init.

class single_user::rhel6 {
    augeas { "single_user":
        context => "/files/etc/sysconfig/init",
        changes => [
# \implements{unixsrg}{GEN000020} Require authentication for access to
# single-user mode.
            "set SINGLE /sbin/sulogin",
# As interactive startup (opportunity to say whether each service will start)
# seems like a ``maintenance mode,'' we'll disable it here.
                "set PROMPT no",
        ],
    }
}
