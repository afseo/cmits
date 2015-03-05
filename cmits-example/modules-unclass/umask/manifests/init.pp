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
# \section{umask}
#
# The \emph{umask} is a set of permissions to \emph{remove} from new
# files being created. For example, files created by a process running
# with a umask of \verb!022! will not be writable by their owning
# group nor everyone else. So the umask acts to provide default file
# permissions. It is inherited by children of a process, so it's
# important to set the umask in shells and process launchers of all
# sorts to ensure that discretionary access controls act to provide
# security.
