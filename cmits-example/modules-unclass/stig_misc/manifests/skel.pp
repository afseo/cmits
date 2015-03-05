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
# \subsection{Secure skel files}

class stig_misc::skel {
# \implements{unixsrg}{GEN001800,GEN001820,GEN001830} Control ownership and
# permissions of skeleton files.
    file { "/etc/skel":
        owner => root, group => 0, mode => 0644,
        recurse => true, recurselimit => 8,
    }
# \implements{unixsrg}{GEN001810} Remove extended ACLs from skeleton files.
    no_ext_acl { "/etc/skel": recurse => true }
}
