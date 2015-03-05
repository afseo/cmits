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
# \section{Passwords}
# \label{passwords}
#
# Implement guidelines regarding passwords.
#
# \subsection{Admin guidance about passwords}
#
# The 2006 UNIX STIG required these things: (GEN000720) Change the root
# password at least every 90 days. (GEN000840) Don't give the root password to
# anyone besides security and administrative users requiring access. Such users
# must be listed under \S\ref{DocumentedWithIAO}. (GEN000860) Change the root
# password whenever anyone who has it is reassigned.
#
# \doneby{admins}{unixsrg}{GEN000740}%
# Change passwords for non-interactive or automated accounts at least once a
# year, and whenever anyone who has one is reassigned.
