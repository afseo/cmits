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
class pam::tally2 {

# \implements{unixsrg}{GEN000460}%
# Lock users out after three bad login attempts.
#
# We use the pam\_tally2 module for this. It's noteworthy that due to where we
# put this module in the stack, if smartcard login is enabled and the user
# presents a valid smartcard and PIN, she is logged in regardless of tally
# count. The reason for this is that the \verb!pam_tally2! module needs to know
# a username, but in the smartcard case, the \verb!pam_pkcs11! module is
# finding that username out---and if it succeeds, the rest of the stack is
# bypassed, including \verb!pam_tally2!. If \verb!pam_tally2! were put first,
# the user would have to enter a username before being prompted for a PIN. In
# terms of total system risk, the requirement to lock out users after three bad
# attempts is made in the context of passwords, and this policy works in the
# context of passwords; in the context of smartcards, the card itself will lock
# after three bad PIN attempts. Either of these taken alone meets the security
# requirement; there should not be many hosts accepting both passwords and CACs
# for authentication of normal users.

    augeas { "system_auth_tally2":
        context => "/files/etc/pam.d/system-auth",
        changes => [
            "rm *[module='pam_tally2.so'][type='auth']",
            "ins 100 before *[module='pam_deny.so' and type='auth']",
            "set 100/type auth",
            "set 100/control required",
            "set 100/module pam_tally2.so",
            "set 100/argument deny=3",
            "set 100/argument[2] audit",
            ],
    }
}
