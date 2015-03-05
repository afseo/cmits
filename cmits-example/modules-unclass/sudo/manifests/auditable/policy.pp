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
# \subsubsection{Basic auditable policy}
#
# The idea here is to make administrators use sudo to run each command
# they need, because sudo logs each command it's run with; and prevent
# administrators from using sudo to run commands that are open-ended,
# in that they can execute more commands (which would not be logged),
# or to run commands that are user-written, because these can be
# anything.

class sudo::auditable::policy {
    include sudo::auditable::whole

# For the noexec type, we allow all local binaries, then disallow
# problematic ones. It's quite important that the
# \verb!LOCAL_BINARIES! directories be only writable by root, and
# that all their files be only writable by root.
#
# These lists can be rather distro-specific and should be checked and
# changed whenever using a new distro or updating to a new major
# version of an existing distro.
    sudo::auditable::command_alias { 'LOCAL_BINARIES':
        commands => [
            '/bin/',
            '/usr/bin/',
            '/sbin/',
            '/usr/sbin/',
            ],
    }
# Disallow \verb!sudo su -!.
    sudo::auditable::command_alias { 'SU':
        enable => false,
        commands => [
            '/usr/bin/su',
            ],
    }
# Shells can execute other things, it's what they do all day long.
    sudo::auditable::command_alias { 'SHELLS':
        enable => false,
        commands => [
            '/bin/sh',
            '/bin/bash',
            '/bin/dash',
            '/bin/ksh',
            '/bin/tcsh',
            '/bin/csh',
            '/bin/zsh',
            ],
    }

# Just about every editor lets you execute commands. So we disable
# them all and allow sudoedit instead. \verb!rvim! and friends seem to
# be OK because they say that when you run them ``it will not be
# possible to start shell commands.''
    sudo::auditable::command_alias { 'EDITORS':
        enable => false,
        commands => [
            '/bin/ed',
            '/bin/vi',
            '/usr/bin/ex',
            '/usr/bin/vim',
            '/usr/bin/view',
            '/usr/bin/evim',
            '/usr/bin/eview',
            '/usr/bin/gvim',
            '/usr/bin/gview',
            '/usr/bin/vimdiff',
            '/usr/bin/vimtutor',
            '/usr/bin/emacs',
            '/usr/bin/emacsclient',
            '/usr/bin/gedit',
            '/usr/bin/kwrite',
            '/usr/bin/nano',
            ],
    }
    sudo::auditable::command_alias { 'SUDOEDIT':
        commands => [
            'sudoedit',
            ],
    }

# For some reason the noexec doesn't catch this, so we prohibit it
# expressly.
    sudo::auditable::command_alias { 'RUNS_SHELL':
        enable => false,
        commands => [
            '/usr/bin/tmux',
            '/usr/bin/screen',
            ],
    }

# For some system files there are special editor wrappers; here we
# compel their use.
    sudo::auditable::command_alias { 'SPECIAL_EDITOR_WRAPPERS':
        type => 'exec',
        commands => [
            '!sudoedit /etc/sudoers',
            '!sudoedit /etc/sudoers.d/*',
            '!sudoedit /etc/passwd',
            '!sudoedit /etc/group',
            '!sudoedit /etc/shadow',
            '!sudoedit /etc/gshadow',
            '/usr/sbin/visudo',
            '/usr/sbin/vipw',
            '/usr/sbin/vigr',
            ],
    }

# Now, broadening out, we have scripts and other binaries with a
# legitimate need to execute subprocesses. Perhaps some of these
# should be listed elsewhere in this policy. That is what our defined
# resource type allows.

    sudo::auditable::command_alias { 'SBIN_SCRIPTS':
        type => 'exec',
        commands => [
            '/sbin/dracut',
            '/sbin/grub-install',
            '/sbin/grub-md5-crypt',
            '/sbin/grub-terminfo',
            '/sbin/ifcfg',
            '/sbin/ifdown',
            '/sbin/ifup',
            '/sbin/mkinitrd',
            '/sbin/service',
            ],
    }
    sudo::auditable::command_alias { 'BIN_SCRIPTS':
        type => 'exec',
        commands => [
            '/bin/gunzip',
            '/bin/zcat',
            '/bin/unicode_start',
            '/bin/unicode_stop',
# \verb!mount! is not a script, but it may run a more specific mount
# binary, so it needs to be able to exec.
            '/bin/mount',
            ],
    }
    sudo::auditable::command_alias { 'USR_SBIN_SCRIPTS':
        type => 'exec',
        commands => [
            '/usr/sbin/gdm',
            '/usr/sbin/ksmtuned',
            '/usr/sbin/virt-what',
            ],
    }
    sudo::auditable::command_alias { 'USR_BIN_SCRIPTS':
        type => 'exec',
        commands => [
            '/usr/bin/batch',
            '/usr/bin/ldd',
            '/usr/bin/mozilla-plugin-config',
            '/usr/bin/startx',
            '/usr/bin/reboot',
            '/usr/bin/halt',
            '/usr/bin/poweroff',
            ],
    }
    sudo::auditable::command_alias { 'CRON_SCRIPTS':
        type => 'exec',
        commands => [
            '/etc/cron.hourly/',
            '/etc/cron.daily/',
            '/etc/cron.weekly/',
            '/etc/cron.monthly/',
            ],
    }
    if $::osfamily == 'RedHat' {
        sudo::auditable::command_alias { 'PACKAGE_MANAGEMENT':
            type => 'exec',
            commands => [
                '/usr/bin/yum',
                '/bin/rpm',
# \verb!/usr/bin/rhn_register! is a symlink to \verb!consolehelper!,
# ``a wrapper that helps console users run system programs''
# (\verb!consolehelper(8)!). What this means for the sudoer is that if
# you run \verb!sudo rhn_register!, this command alias will not match
# it, and the one above for local binaries will, and it won't be
# allowed to execute subprocesses, and it won't work. But if you run
# \verb!sudo /usr/bin/rhn_register!, it will work right.
                '/usr/bin/rhn_register',
# \verb!rhnreg_ks! is not allowed here, because you have to pass it a
# password on the command line, and that's stored in your history
# file, and visible to everyone logged in on the host while it's
# running.
                ],
        }
    }
}
