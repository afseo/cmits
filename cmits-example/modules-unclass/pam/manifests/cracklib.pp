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
class pam::cracklib {
# \implements{unixsrg}{GEN000790}%
# Enforce password guessability guidelines using the {\tt pam\_cracklib}
# module. This module first tries to look the password up in a dictionary using
# {\tt cracklib}, then applies strength checks as directed.
    augeas { "system_auth_cracklib":
        context => "/files/etc/pam.d/system-auth",
        changes => [
            "rm *[type='password'][module='pam_cracklib.so']",
            "ins 100 before *[type='password' and module!='pam_centrifydc.so'][1]",
            "set 100/type password",
            "set 100/control requisite",
            "set 100/module pam_cracklib.so",
# \implements{unixsrg}{GEN000580}%
# Require a minimum password length of 14 characters.
            "set 100/argument[1] minlen=14",
# \implements{unixsrg}{GEN000600}%
# Require passwords to contain at least one uppercase letter.
            "set 100/argument[2] ucredit=-1",
# \implements{unixsrg}{GEN000610}%
# Require passwords to contain at least one lowercase letter.
            "set 100/argument[3] lcredit=-1",
# \implements{unixsrg}{GEN000620}%
# Require passwords to contain at least one digit.
            "set 100/argument[4] dcredit=-1",
# \implements{unixsrg}{GEN000640}%
# Require passwords to contain at least one other (special) character.
            "set 100/argument[5] ocredit=-1",
# Prevent users from using parts of their usernames in their passwords.
#
# (This and a few other things were GEN000660 in the 2006 UNIX STIG.)
            "set 100/argument[6] reject_username",
# \implements{unixsrg}{GEN000680}%
# Prohibit the repetition of a single character in a password more than three
# times in a row.
            "set 100/argument[7] maxrepeat=3",
# Let the user have three attempts at entering a strong password.
            "set 100/argument[8] retry=3",
# \implements{unixsrg}{GEN000750}%
# Require that at least four characters be changed between the old and new
# passwords.
#
# (When changing this setting, see the man page for \verb!pam_cracklib!: the
# exact semantics of the difok parameter are slightly different from the
# semantics of the STIG requirement.)
            "set 100/argument[9] difok=4",
            ],
    }
}
