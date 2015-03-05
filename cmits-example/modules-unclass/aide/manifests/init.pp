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
# \section{Host-based intrusion detection with AIDE}
# \label{aide}
#
# \implements{unixsrg}{GEN000140,GEN006480}%
# \implements{rhel5stig}{GEN000140-2}%
# Install and configure the Advanced Intrusion Detection Environment (AIDE)
# host-based intrusion detection system (IDS) to check system files against a
# list of cryptographic hashes (a baseline) created at install time.
# (See~\S\ref{Baselining} for baseline creation and update procedures.)
#
# \implements{iacontrol}{DCSW-1}\implements{databasestig}{DG0021}%
# For DBMSes included with RHEL, maintain the baseline for database software
# and configuration files along with that of the operating system files. (See
# also~\S\ref{class_rpm::stig}.)
#
# \implements{unixsrg}{GEN002380,GEN002440} Document setuid and setgid files,
# by including them in the baseline of system files.
#
# \implements{unixsrg}{GEN006560} Notify admins of possible intrusions via
# syslog. Remote logging ensures timely notification; for details,
# see~\S\ref{module_log}.
#
# \implements{unixsrg}{GEN008380} Check for rootkits. The AIDE tool does this
# adequately for our needs.

class aide {
    include "aide::${::osfamily}"
}
