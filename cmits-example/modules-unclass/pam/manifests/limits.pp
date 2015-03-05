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
# \subsection{pam\_limits}
#
# Make sure that \verb!pam_limits.so! is called by the PAM configuration.

class pam::limits {
    augeas {
        "pam_limits_insert":
            context => "/files/etc/pam.d/system-auth",
            onlyif => "match *[type='session' and \
                               module='pam_limits.so'] \
                       size == 0",
            changes => [
                "insert 999 before *[type='session' and module!='pam_centrifydc.so'][1]",
                "set 999/type session",
                "set 999/control required",
                "set 999/module pam_limits.so",
            ];
        "pam_limits_require":
            require => Augeas["pam_limits_insert"],
            context => "/files/etc/pam.d/system-auth",
            changes => "set *[\
                    type='session' and \
                    module='pam_limits.so']/control \
                required";
    }
}
