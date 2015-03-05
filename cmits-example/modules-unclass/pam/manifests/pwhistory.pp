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
class pam::pwhistory {
# Use the pam\_pwhistory module to make sure passwords are not reused within
# the last ten changes. First, make sure there is a line in the right place
# calling pam\_pwhistory:
    augeas { "system_auth_pwhistory":
        require => Augeas["system_auth_cracklib"],
        context => "/files/etc/pam.d/system-auth",
        changes => [
            "rm *[type='password'][module='pam_pwhistory.so']",
            "ins 100 after *[type='password']\
[module='pam_cracklib.so' or module='pam_centrifydc.so'][last()]",
            "set 100/type password",
            "set 100/control requisite",
            "set 100/module pam_pwhistory.so",
# \implements{unixsrg}{GEN000800}%
# Remember the last ten passwords and prohibit their reuse.
            "set 100/argument[1] remember=10",
# Do this even for root.
            "set 100/argument[2] enforce_for_root",
# Don't prompt for another password: use the one from the module above this
# one.
            "set 100/argument[3] use_authtok",
            ],
    }
}
