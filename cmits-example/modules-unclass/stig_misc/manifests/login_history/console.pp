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
# \subsubsection{At the console}
#
# For this we use \verb!pam_lastlog.so!.

class stig_misc::login_history::console {
# First make sure that \verb!pam_lastlog! is called by the PAM configuration.
    augeas { "pam_lastlog_insert":
        context => "/files/etc/pam.d/system-auth",
        onlyif => "match *[type='session' and \
                           module='pam_lastlog.so'] \
                   size == 0",
        changes => [
            "insert 999 after *[type='session'][last()]",
            "set 999/type session",
            "set 999/control required",
            "set 999/module pam_lastlog.so",
        ],
    }
# Now---set its parameters.
    augeas { "pam_lastlog_parameters":
        context => "/files/etc/pam.d/system-auth/*[\
                 type='session' and \
                 module='pam_lastlog.so']",
        changes => [
            "rm argument",
            "set argument showfailed",
        ]
    }
}
