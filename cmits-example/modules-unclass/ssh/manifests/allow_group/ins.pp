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
# When multiple \verb!ssh::allow_group! resources are defined, they all need
# this, and they cannot contain it within themselves, because then it would be
# repeated; and you only get to have one Augeas named
# \verb!sshd_ins_allow_group!.

class ssh::allow_group::ins {
    augeas { "sshd_ins_allow_group":
        context => "/files${ssh::server_config}",
        changes => "ins AllowGroups after *[last()]",
        onlyif => "match AllowGroups size == 0";
    }
}

