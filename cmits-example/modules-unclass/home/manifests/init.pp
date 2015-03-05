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
# \section{Home directories}
#
# Apply policies to the home directories of users.
#
# This is harder than it sounds, mostly because the set of home directories
# varies from host to host, and no policy can be applied to them all as a
# whole, but they must each be treated separately.
#
# In accordance with \unixsrg{GEN003620}, there is a separate file system for
# user home directories, \verb!/home!; so the custom fact \emph{home\_perms} is
# the collection of home directories listed in \verb!/etc/passwd! which are
# under \verb!/home!, along with the user ID and primary group ID of its
# rightful owner.
#
# Since Facter only makes facts which are strings, but we need a list of
# triples, delimiters are inserted into the \emph{home\_perms} fact, and here
# in the \verb!home! class we split the fact back up. A further restriction is
# that when arrays are used to define multiple resources in Puppet, it appears
# that further parameters unique to each resource cannot be provided; so all of
# the pieces of data needed must be squished into the resource's name. So the
# name of a home directory resource looks like \verb!/home/user:uid:gid!, and
# any defined resource types must use the \verb!split! function to take this
# apart. In this way, each home directory along with its rightful owner and
# group can make its way from the \verb!/etc/passwd! file, through Facter, into
# Puppet as an instance of one or more \verb!home::*! defined resource types.

class home {
    $home_perms_a = split($home_perms, ',')
    home::quick { $home_perms_a: }
    home::slow { $home_perms_a: }
}

#
# We have NFS-mounted home directories on most of our hosts, and all of the
# normal ones do not have root access to that NFS share (\unixsrg{GEN005880}
# is related to this issue, but our NFS servers do not run UNIX).
#
# In future a host will be dedicated to applying policies to NFS homes. For now
# we limit ourselves to enforcing the policies against local homes. 
#
# \subsection{Admin guidance about home directories}
#
# \doneby{admins}{unixsrg}{GEN001960}%
# Administrators, ``educate users about the danger of having terminal messaging
# set on.''
#
# \subsection{User guidance about home directories}
#
# The SRG imposes requirements on the contents of local initialization files,
# which cannot be programmatically enforced without an extraordinarily severe
# uniformity, nor automatically checked for. These files are
# \verb!$HOME/.bashrc!, \verb!$HOME/.profile! and the like. You are responsible
# for fulfilling these requirements:
#
# \doneby{users}{unixsrg}{GEN001900}%
# Do not add an entry to your \verb!PATH! which is not an absolute path. This
# prohibition includes \verb!.!, the current directory.
#
# \doneby{users}{unixsrg}{GEN001901}%
# Do not add an entry to your \verb!LD_LIBRARY_PATH! which is not an absolute
# path.
#
# \doneby{users}{unixsrg}{GEN001902}%
# Do not set the \verb!LD_PRELOAD! environment variable.
#
# \doneby{users}{unixsrg}{GEN001940}%
# Do not execute world-writable programs from your local initialization files.
# If you build programs, make sure they don't end up world-writable.
#
# \doneby{users}{unixsrg}{GEN001960}%
# Do not place the command \verb!mesg y! in your startup files.
#
# \doneby{users}{iacontrol}{IAIA-1}\doneby{users}{databasestig}{DG0067}%
# Do not set the \verb!PGPASSFILE! environment variable.
