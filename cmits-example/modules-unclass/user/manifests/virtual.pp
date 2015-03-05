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
class user::virtual {
    User {
        shell => '/bin/bash',
        ensure => 'present',
        password => '!!',
    }

    @user {
        logview:
            comment => "Log viewing user",
            gid => logview, uid => 49152;
        'puppet_dba':
            comment => "OS user used by Puppet to administer PostgreSQL",
            gid => puppet_dba, uid => 49153;
    }

    @group {
        logview:
            gid => 49152;
        puppet_dba:
            gid => 49153;
    }
}
