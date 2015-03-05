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
# \subsection{Set login failure delay}

class pam::faildelay($seconds) {

# The delay argument is in microseconds, so we convert.
    $microseconds = $seconds * 1000000

    augeas { "pam_faildelay":
        context => "/files/etc/pam.d/system-auth",
        changes => [
            "rm *[type='auth'][module='pam_faildelay.so']",
            "insert 999 before *[type='auth' and module!='pam_centrifydc.so'][1]",
            "set 999/type auth",
            "set 999/control required",
            "set 999/module pam_faildelay.so",
            "set 999/argument delay=$microseconds",
        ],
    }
}
