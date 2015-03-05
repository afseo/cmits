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
# \subsection{Get filer users from an agent host}
#
# With an integration between Active Directory and UNIX hosts such as
# Centrify, UNIX users need to be populated to the filer. This define
# gathers non-system users from a host and places them in group and
# passwd files in the filer's \verb!etc! directory, which is indicated
# by the name of the resource.

define filers::users_from_agent($etc_dir, $ensure='present') {
    include filers::remove_old_users_from_agent
    file { "/etc/cron.hourly/${name}_users_and_groups":
        owner => root, group => 0, mode => 0755,
        content => template('filers/users_to_filer.cron'),
        ensure => $ensure,
    }
}
