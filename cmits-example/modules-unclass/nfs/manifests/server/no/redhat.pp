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
# \paragraph{Turn off NFS server on Red Hat machines}
#
# We can't remove the NFS server software on Red Hat because it comes
# in the same package as the NFS client software. But we can stop the
# services.

class nfs::server::no::redhat {
    service { 'nfs':
        ensure => stopped,
        enable => false,
    }
}
