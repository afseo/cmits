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
# How the filer policy agent can make a directory for me to back up my logs in:
define log::backup::to_net_admin::for_host {
    file {
        "/net/admin/BACKUPS/${name}":
            ensure => directory,
            owner => root, group => skadmin, mode => 2755;
        "/net/admin/BACKUPS/${name}/LOGS":
            ensure => directory,
            owner => root, group => skadmin, mode => 2755;
    }
}
