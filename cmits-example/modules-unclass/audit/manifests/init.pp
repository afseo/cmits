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
# \section{Auditing subsystem}
# \label{audit}
#
# % ECAN-1, implementation guidance, (2)(f) requires auditing.
#
# \implements{iacontrol}{ECAN-1,ECRR-1}%
# Activate audit logging; configure it in a compliant fashion; and protect and
# retain audit logs.
#
# The sense in which we implement ECRR-1, Audit Record Retention, here in this
# section, is that retention includes making sure the logs are not overwritten,
# nor modified or deleted by unauthorized users. The narrower sense of
# retention, ``moving audit trails from on-line to archival media,'' is handled
# by backing up the audit logs in the same way as the rest of the logs.
# See~\S\ref{module_log}.
#
# \unimplemented{unixsrg}{GEN002870}{The SRG requires remote audit logging. It
# seems that audisp-remote can be used for remote audit logging, but it needs a
# Kerberos infrastructure first. So we do not yet have a remote audit server.
# We depend on log backups to preserve a remote audit record.}
#
# \implements{iacontrol}{ECAR-2}\implements{databasestig}{DG0140}%
# The auditing rules installed in~\S\ref{audit} fulfill Database STIG
# requirements.

class audit {
    include "audit::${::osfamily}"
    include audit::file_permissions
}
