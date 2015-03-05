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
# \subsubsection{Passwords under Red Hattish Linuxen}

class passwords::stig::redhat {

# We need the augeas class because it teaches Augeas the format of the
# \verb!login.defs! file.

    include pam::tally2
    include pam::cracklib
    include pam::pwhistory

    require augeas
    augeas {
# Enforce minimum and maximum password ages.
        "passwords_stig_login_defs":
            context => "/files/etc/login.defs",
            changes => [
# \implements{unixsrg}{GEN000540}%
# Don't let users change passwords more than once a day.
                "set PASS_MIN_DAYS 1",
# \implements{unixsrg}{GEN000700}%
# Require users to change their passwords at least every 60 days.
                "set PASS_MAX_DAYS 60",
# \implements{unixsrg}{GEN000585}%
# Enforce the correctness of the entire password, not just the first eight
# characters of it.
#
# The man page says that the PASS\_MIN\_LEN and PASS\_MAX\_LEN in
# \verb!/etc/login.defs! are ignored when MD5 passwords are enabled---meaning
# that none of the password is thrown away when hashing or applying length and
# strength rules. The operative minimum password length is specified above in
# section configuring cracklib; for any decent hashing function there is no
# maximum length, because it all gets hashed to the same length.
#
# \implements{unixsrg}{GEN000590,GEN000595}%
# Use a FIPS 140-2 approved algorithm for hashing account passwords.
#
# The man page further says that the MD5\_CRYPT\_ENAB variable is superseded by
# ENCRYPT\_METHOD. That's good, because MD5 is broken and SHA1 is almost. The
# discussion on this PDI requires specifically something in the SHA-2 family of
# algorithms; we'll use the SHA-256 variant.
#
# \bydefault{RHEL6}{unixsrg}{GEN000588}%
# Red Hat Enterprise Linux 6 hashes passwords using only FIPS-approved hashing
# algorithms, performed by approved cryptographic modules running in
# FIPS-compliant mode.
#
# According to \url{https://bugzilla.redhat.com/show_bug.cgi?id=504949#c37} and
# a check of
# the dependencies of the glibc RPM package in RHEL6, glibc's libcrypt, used by
# pam\_unix to hash passwords, uses NSS for cryptographic hashing. See
# \ref{class_fips} for details on FIPS accreditation status of NSS. RHEL5 may
# or may not be compliant with this requirement.
                "set ENCRYPT_METHOD SHA256",
            ];

# \implements{unixsrg}{GEN000760}%
# Disable accounts when passwords expire.
#
# The requirement is after 35 days of inactivity, but I can't find anywhere
# where that this can be configured other than as an interval after password
# expiration.
        "expire_on_password_expire":
            context => "/files/etc/default/useradd",
            changes => "set INACTIVE 0";
    }

# \implements{unixsrg}{GEN000560}%
# Log an error if any user is known to have an empty password.
#
# This will only detect empty passwords for users whose passwords are stored
# locally.
    exec { "no_empty_passwords":
        path => ['/bin'],
        command =>
            "echo ---- USERS WITH EMPTY PASSWORDS ----; \
             grep '^[^:]\\+::' /etc/shadow",
        onlyif  => "grep '^[^:]\\+::' /etc/shadow",
        loglevel => err,
        logoutput => true,
    }

    include passwords::only_shadow
    include passwords::no_gshadow
}
