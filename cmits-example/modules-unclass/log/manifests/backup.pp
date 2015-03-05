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
# \subsection{Log backup}
#
# \verb!rsyslog! should log remotely in most cases, and logs can be backed up
# from the loghost. But limited use in practice indicates that \verb!rsyslog!
# may fail to send log messages under some conditions, and its incomplete PKI
# support means remote logging may become infeasible in our case, given
# security requirements.
#
# Remotely logged messages are saved in files on the loghost. Log messages are
# always written to local files, whether they are sent remotely or not. Audit
# messages are only written to local files: we have no remote audit logging
# capability at present.
#
# \implements{iacontrol}{ECRR-1} Back up audit logs and other logs to archival
# media. Retain them for one year, or five years for systems containing sources
# and methods intelligence (SAMI).
#
# Exactly how logs are backed up and to where depends on to which network a
# host is connected. \verb!log::backup::*! classes make various
# implementations of log backup happen. This \CMITSPolicy\ may not cover the
# entire journey of log backups to archival media: consult the Backup Policy
# \cite{backup-policy} in addition.
