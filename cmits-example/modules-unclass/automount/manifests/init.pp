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
# \section{Automount}
# \label{automount}
#
# Mount NFS filesystems via the automounter, under \verb!/net!.
#
# \implements{unixsrg}{GEN008440}%
# ``Automated file system mounting tools must not be enabled unless needed,''
# because they ``may provide unprivileged users with the ability to access
# local media and network shares.'' This automount configuration does not
# enable access to local media, and constricts network share access to filers
# designated for the purpose of serving unprivileged users.

class automount {
# If we're automounting we're going to be using NFS. Make sure we're prepared
# for that.
    include nfs

    include "automount::${::osfamily}"
}
