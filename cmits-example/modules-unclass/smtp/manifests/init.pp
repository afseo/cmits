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
# \section{SMTP}
#
# Configure SMTP properly. This whole module is presently RHEL6-specific and
# Postfix-specific.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN004400}%
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN004410}%
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN004420}%
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN004430}%
# The default RHEL aliases file does not contain any entries which execute
# programs.
#
# \notapplicable{unixsrg}{GEN004440}%
# We use postfix, not sendmail.
#
# \bydefault{RHEL6}{unixsrg}{GEN004460}%
# RHEL6 logs all mail server messages by default.
#
# \bydefault{RHEL6}{unixsrg}{GEN004540}%
# Postfix does not recognize the SMTP \verb!HELP! command.
#
# \bydefault{RHEL6}{unixsrg}{GEN004560}%
# Postfix under default RHEL6 settings does not divulge its version in its
# greeting.
#
# \bydefault{RHEL6}{unixsrg}{GEN004600}%
# Red Hat provides up-to-date SMTP servers.
#
# \notapplicable{unixsrg}{GEN004620}%
# We use postfix, not sendmail.
#
# \bydefault{RHEL6}{unixsrg}{GEN004660}%
# Postfix does not recognize the SMTP \verb!EXPN! command.
#
# \bydefault{RHEL6}{unixsrg}{GEN004680}%
# Postfix does not provide any information in response to an SMTP \verb!VRFY!
# request.
#
# \bydefault{RHEL6}{unixsrg}{GEN004700}%
# Postfix does not recognize the SMTP \verb!WIZ! command.
#
# \bydefault{RHEL6}{unixsrg}{GEN004710}%
# Postfix under default RHEL6 settings accepts email only from the local
# system. This policy does not change this default.

class smtp {
# When the aliases file has changed, run newaliases. Our edits using Augeas
# will notify this exec resource.
    exec { "newaliases":
        command => "/usr/bin/newaliases",
        refreshonly => true,
    }

# \implements{unixsrg}{GEN004480}%
# Control ownership of the SMTP log.  (Permissions and ACLs are controlled
# by~\S\ref{class_log::stig}.)
    file { "/var/log/maillog": owner => root }
}

# \subsection{Admin guidance regarding SMTP}
#
# \doneby{admins}{unixsrg}{GEN004400,GEN004410,GEN004420,GEN004430}%
# Do not add any entries to the aliases file which execute programs.
#
