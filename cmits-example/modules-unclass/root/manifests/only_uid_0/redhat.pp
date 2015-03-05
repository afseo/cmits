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
class root::only_uid_0::redhat {
# \implements{unixsrg}{GEN000880}%
# Make sure root is the only user with a user id of 0.
#
# Log an error if any account besides root has a user id of 0. Do this
# by finding all users with a uid of 0, ignoring root (using
# \verb!grep -v!). If any results remain to be printed, \verb!grep!
# will exit with 0 (success). Then the command will be executed and
# its output logged as errors. N.B. \verb!augtool match! does not
# reliably exit with any given exit code, so we must rely on grep
# here. See
# \url{http://www.redhat.com/archives/augeas-devel/2010-January/msg00100.html}.
    exec { "only_root_uid_0":
        onlyif =>
            "augtool match \
             /files/etc/passwd/\\*/uid[.=\\'0\\'] \
             | grep -v '^/files/etc/passwd/root/uid = 0'",
        command =>
            "augtool match \
             /files/etc/passwd/\\*/uid[.=\\'0\\'] \
             | grep -v '^/files/etc/passwd/root/uid = 0'",
        logoutput => true,
        loglevel => err,
        require => Class['augeas'],
    }
}
