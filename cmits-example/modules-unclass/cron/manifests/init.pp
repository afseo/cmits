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
# \section{Cron}
# \label{cron}
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN003160}%
# RHEL implements cron logging by default.
#
# \subsection{Automated policy}
#
class cron($allowed_users=[]) {

    $crontab = $::osfamily ? {
        'darwin' => '/private/var/at/tabs/root',
        'redhat' => '/etc/crontab',
        default  => unimplemented,
    }
    $cron_allow = $::osfamily ? {
        'darwin' => '/private/var/at/cron.allow',
        'redhat' => '/etc/cron.allow',
        default  => unimplemented,
    }
    $cron_deny = $::osfamily ? {
        'darwin' => '/private/var/at/cron.deny',
        'redhat' => '/etc/cron.deny',
        default  => unimplemented,
    }
# Under Snow Leopard, \verb!/usr/lib/cron! is a symlink to \verb!../../var/at!,
# and \verb!/var! is a symlink to \verb!/private/var!.
#
# \verb!cron! usually does daily tasks at 4:00 am or so. Sometimes we have
# tasks that need to send routine email to real people who may have
# Blackberries, so that emailing them at four in the morning would be a bad
# idea. For such tasks, we have \verb!cron.morningly!.
    $cron_dirs = $::osfamily ? {
        'darwin' => [ '/private/var/at' ],
        'redhat' => [ '/etc/cron.d', '/etc/cron.morningly',
                     '/etc/cron.hourly', '/etc/cron.daily',
                     '/etc/cron.weekly', '/etc/cron.monthly' ],
        default  => unimplemented,
    }
    $cron_tools = $::osfamily ? {
        'darwin' => [ '/usr/sbin/cron', '/usr/bin/crontab' ],
        'redhat' => [ '/usr/sbin/crond', '/usr/bin/crontab' ],
        default  => unimplemented,
    }

    file {
# \implements{unixsrg}{GEN003250}%
# Make sure only root can edit the {\tt cron.allow} file.
        $cron_allow:
            owner => root, group => 0, mode => 0600;
# \implements{macosxstig}{GEN003270 M6}%
# \implements{unixsrg}{GEN003270}%
# Make sure only root can edit the {\tt cron.deny} file.
        $cron_deny:
            owner => root, group => 0, mode => 0600;

# \implements{unixsrg}{GEN003040,GEN003050,GEN003080}%
# Restrict access to the system {\tt crontab} to only root.
        $crontab:
            owner => root, group => 0, mode => 0600;

# \implements{macosxstig}{GEN003400 M6, GEN003420 M6}%
# Control ownership and permissions of the ``at'' directory, which under Mac OS
# X is the same as the ``cron'' directory.
#
# \implements{unixsrg}{GEN003100,GEN003120,GEN003140}%
# Under RHEL, restrict access to directories used by {\tt run-parts}, which
# contain scripts to be run periodically, to only root.
# \implements{rhel5stig}{GEN003080-2}%
# Also restrict access to the files in these directories.
        $cron_dirs:
            ensure => directory,
            owner => root, group => 0, mode => go-rwx,
            recurse => true, recurselimit => 2;
    }

    no_ext_acl {
# \implements{macosxstig}{GEN002990 M6}%
# \implements{unixsrg}{GEN002990}%
# Remove extended ACLs on \verb!cron.allow!.
# \implements{unixsrg}{GEN003245}%
# Remove extended ACLs on \verb!cron.allow!.
        $cron_allow:;
# \implements{unixsrg}{GEN003090}%
# Remove extended ACLs on \verb!crontab!.
        $crontab:;
# \implements{unixsrg}{GEN003110}%
# Remove extended ACLs on directories used by \verb!run-parts!.
        $cron_dirs:;
# \implements{unixsrg}{GEN003210}%
# Remove extended ACLs on \verb!cron.deny!.
        "/etc/cron.deny":;
    }

    case $::osfamily {
        'redhat': {
            cron { morningly:
                command => "run-parts /etc/cron.morningly",
                user => root,
                hour => 8,
                minute => 2,
            }
# \implements{unixsrg}{GEN002960,GEN002980,GEN003060,GEN003240}%
# Under RHEL, control usage of the \verb!cron! utility.
#
# The STIG doesn't say it has to be only usable by root: merely that
# its use must be controlled by the use of \verb!cron.allow! and
# \verb!cron.deny! files.
            File[$cron_allow] {
                content +> inline_template("
root
<% @allowed_users.to_a.each {|user| %>
<%=user %>
<% } %>"),
            }
# \implements{unixsrg}{GEN003200,GEN003260,GEN003270}%
# Under RHEL, remove the {\tt cron.deny} file if it exists.
            File[$cron_deny] {
                ensure +> absent,
            }
        }
# Under Mac OS X, it appears we cannot limit cron usage to root only, because
# some antivirus software may depend on its use with non-root users. Also we
# don't yet do anything morningly on Macs, so we needn't worry about setting it
# up.
        'darwin': {}
        default:  {}
    }
}
#
# \subsection{Guidance for administrators about cron}
#
# \doneby{admins}{unixsrg}{GEN003220}%
# Don't write a cron script that changes the umask.
#
# System administrators who need to accomplish periodic tasks which should not
# be run as root should write scripts that use su or sudo to become the
# appropriate user before beginning the task.
#
# \doneby{admins}{iacontrol}{DCSL-1}%
# \doneby{admins}{unixsrg}{GEN003000,GEN003020}%
# Before writing or deploying a cron script, make sure it will not execute
# group- or world-writable programs, nor execute programs in or under
# world-writable directories.
