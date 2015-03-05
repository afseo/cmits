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
# \subsection{Limit SSH login by group membership}
#
# \implements{unixsrg}{GEN005521} Restrict login via SSH to members of certain
# groups.
#
# (If any groups are listed in the \verb!AllowGroups! directive of the
# \verb!sshd! configuration, all other groups are denied login.)
#
# Note that while this define can add a group to the AllowGroups directive, it
# cannot take one away. Taking some away would require knowing the entire set
# of them, but each \verb!ssh::allow_group! only knows about itself. Perhaps
# some cunning artificer could use virtual resources to make this work right,
# but I'm not that person right now.

define ssh::allow_group() {
    include ssh
    include ssh::allow_group::ins
    augeas {
        "sshd_allow_group_${name}":
            require => Augeas["sshd_ins_allow_group"],
            context => "/files${ssh::server_config}",
            changes => [
                "set AllowGroups/10000 '${name}'",
            ],
            onlyif => "match AllowGroups/*[.='${name}'] \
                       size == 0";
    }
}
