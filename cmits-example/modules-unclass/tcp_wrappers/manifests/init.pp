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
# \section{TCP Wrappers}
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN006580}%
# RHEL comes with TCP wrappers enabled by default.
#
# \bydefault{RHEL5, RHEL6}{unixsrg}{GEN006600}%
# ``The system's access control program must log each system access attempt.''
# RHEL logs all access attempts by default.
#
# TCP wrappers are used within this policy solely to control SSH access. RHEL's
# \verb!sshd! logs all successful and failed access attempts. This materially
# prevents ``multiple attempts to log on to the system by an unauthorized
# user'' from ``go[ing] undetected.'' If we were to enable additional services
# using xinetd, it would also log all connection attempts by default.
#
# Services which are not implemented on a host are not presently booby-trapped
# using TCP wrappers, so unauthorized users could (for example) attempt to
# telnet to a host repeatedly, and nothing would be logged by ``the system's
# access control program.'' That would result in incoming packets which are not
# explicitly allowed, which would most likely be logged via other means: see
# \S\ref{class_iptables}.
#
# \implements{unixsrg}{GEN006620}%
# Configure {\tt tcp\_wrappers} to grant or deny system access to specific
# hosts.
#
# Use of the \verb!tcp_wrappers::allow! defined resource type below will
# ``configure'' TCP wrappers ``with appropriate rules.''
