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
# \section{Unowned files and directories}
#
# \implements{macosxstig}{GEN001160 M6,GEN001170 M6}%
# Fix \emph{unowned} files and directories, defined as those whose numerical
# owner UID or group-owner GID do not map to a known user or group.
# 
# The check content of \macosxstig{GEN001160 M6} makes it clear that no unowned
# files or directories should exist anywhere on the system. But on any given
# UNIX workstation, some directories may be shared over a network, which makes
# the potential set of files to check not only uncomfortably large, but also
# redundant between hosts. Additionally, some of the shared directories may not
# be mounted in such a fashion that \verb!root! can change the owner or group
# of files and directories therein, so not all hosts could fix an unowned file
# or directory should they come across one.
#
# Accordingly the plan for making sure all files and directories are validly
# owned will vary between networks and between hosts. Classes in this module
# will take care of different parts of the namespace to provide the tools
# necessary for a complete defense against this threat.
