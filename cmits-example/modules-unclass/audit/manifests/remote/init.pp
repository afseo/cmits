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
# \subsection{Remote audit logging}
#
# % Remove this when remote audit logging is done.
# \doneby{admins}{iacontrol}{ECRG-1}%
#
# Remote audit logging in our environment has the following requirements:
# \begin{enumerate}
# \item Make it harder for an attacker who compromises a server to redact its
# audit log, by sending auditing data from the subject server off to another
# server.
# \item Make it hard for non-admins to see what audit messages result from a
# given stimulus to the server, by hiding audit messages from non-admins.
# \item Use encryption rather than a separate network to do this hiding:
# multiple networks connected to one host can cause allergic reactions in some
# accreditors.
# \item Use a different means of encrypting and sending audit messages than the
# one used for sending system log messages, to avoid a single point of failure.
# (rsyslogd's SSL remote logging seems a bit flaky in practice.)
# \item Be as simple as possible within these constraints.
# \end{enumerate}
#
# The Linux auditing subsystem supports encrypted remote audit logging using
# Kerberos for authentication and encryption. For each host sending its audit
# data off remotely, there must be a Kerberos principal. In order to avoid
# imposing the unique security requirements of the auditing subsystem on any
# organization-wide Kerberos deployment, a Kerberos realm dedicated for remote
# auditing is set up.

