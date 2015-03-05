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
# \subsection{Guard hashed passwords}
#
# Make sure that password hashes are not stored in the \verb!/etc/passwd! or
# \verb!/etc/group! files, which are readable to everyone: if everyone can read
# a hashed password, someone can take it somewhere else and figure out the
# password by brute computational force.

class passwords::only_shadow {
# \implements{unixsrg}{GEN001470} Make sure the passwd file does not
# contain password hashes.
#
# (A side effect of this command is to warn if anyone has an empty password in
# \verb!/etc/passwd!.)
    exec { "passwd_no_hashes":
        command => "/bin/grep -v '^[^:]\\+:x:' /etc/passwd",
        onlyif  => "/bin/grep -v '^[^:]\\+:x:' /etc/passwd",
        logoutput => true,
        loglevel => err,
    }
# \implements{unixsrg}{GEN001475} Make sure the group file does not contain
# password hashes.
#
# (A side effect of this command is to warn if any group has an empty password
# in \verb!/etc/group!.)
    exec { "group_no_hashes":
        command => "/bin/grep -v '^[^:]\\+:x:' /etc/group",
        onlyif  => "/bin/grep -v '^[^:]\\+:x:' /etc/group",
        logoutput => true,
        loglevel => err,
    }
}
