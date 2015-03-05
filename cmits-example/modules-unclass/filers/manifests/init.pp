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
# \section{Filer policy}
#
# Our filers store files and make them accessible over the network. There is
# policy which applies to the filers, but they run proprietary operating
# systems which cannot run Puppet. So some hosts are designated as \emph{filer
# policy agents}, given elevated access to the filers (e.g. allowed to NFS
# mount volume \verb!vol0! on Network Appliance filers), and tasked to enforce
# the policy.
