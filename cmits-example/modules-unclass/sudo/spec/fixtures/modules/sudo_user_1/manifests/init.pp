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
class sudo_user_1 {
    include sudo::auditable::whole
    sudo::auditable::command_alias { 'EDITORS':
	commands => ['/usr/bin/vim', '/usr/bin/emacs'],
    }
    sudo::auditable::command_alias { 'SINGLE_MEMBER_ARRAY':
	commands => ['/bin/true'],
        type => 'setenv_exec',
    }
    sudo::auditable::command_alias { 'SINGLE_ITEM':
	commands => '/bin/false',
    }
    sudo::auditable::command_alias { 'BAD_STUFF':
        commands => '/sbin/fdisk',
        enable => false,
    }
    sudo::auditable::for { '%luckygroup': }
}
