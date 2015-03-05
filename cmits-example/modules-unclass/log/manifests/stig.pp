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
# \subsection{STIG-required logging configuration}

class log::stig {
# \implements{unixsrg}{GEN001260}%
# \implements{macosxstig}{GEN001260 M6}%
# Control permissions on all system log files.
#
# Make all system log files have mode \verb!0640! or less permissive.
#
# This is a pair of execs and not a file resource type because the file
# resource type can't set a different mode for a directory versus its contents.
# (We need to be careful because some files under \verb!/var/log! already have
# more restrictive permissions than \verb!0640!, so to use a numeric mode would
# be painting with too wide a brush.)
#
# GNU chmod, when called with \verb!-v!, will ``output a diagnostic
# for every file processed.'' The \verb!-c! switch will ``report only
# when a change is made.'' Mac (BSD?) chmod \verb!-v!, on the other
# hand, says it will show filenames ``as the mode is modified.'' This
# latter chmod does not recognize the \verb!-c! switch and will fail
# if it is given.
    $verbose_chmod = $::osfamily ? {
        'RedHat' => '/bin/chmod -c',
        'Darwin' => '/bin/chmod -v',
        default  => '/bin/chmod -v',
    }

# \implements{unixsrg}{GEN003180}%
# Secure \verb!cron! logs.
# \implements{unixsrg}{GEN004500}%
# Secure SMTP logs.
    exec { "var_log_contents_other_minus_read":
        command => "${verbose_chmod} -R o-rwx,g-w /var/log",
        logoutput => true,
    }
    exec { "var_log_self_read_ok":
        command => "${verbose_chmod} o+rx /var/log",
        logoutput => true,
        require => Exec["var_log_contents_other_minus_read"],
    }
# \implements{unixsrg}{GEN001270,GEN003190,GEN004510}%
# \implements{macosxstig}{GEN001270 M6}%
# \implements{mlionstig}{OSX8-00-00825}%
# Remove extended ACLs on system log files (including SMTP and \verb!cron!
# logs).
    no_ext_acl { "/var/log": recurse => true }

# Some SRG requirements regard the system logging configuration file. The name
# of the system logging configuration file depends on which system logger is in
# use. See the class for the relevant logger for the implementations of those
# requirements.
#
# Impose platform-specific configurations on log files:
    include "log::stig::${::osfamily}"
}

# \subsection{Admin guidance regarding logging}
#
# \doneby{admins}{unixsrg}{GEN005440}%
# Do not cause unencrypted log traffic to cross enclave boundaries.
