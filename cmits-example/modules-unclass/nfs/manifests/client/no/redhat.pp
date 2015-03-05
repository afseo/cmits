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
# \subsection{Remove rpcbind}
#
# \implements{unixsrg}{GEN003810,GEN003815} Remove the rpcbind or portmap
# service wherever it is not necessary (it is necessary where NFS is in use).

class nfs::client::no::redhat {
    case $operatingsystemrelease {
        /6\..*/: {
# We have to do this using an exec because the package type can only
# remove one package at a time, but nfs-utils and nfs-utils-lib each
# depend on the other, so neither can be successfully removed by
# itself. See \url{http://projects.puppetlabs.com/issues/2198}.
            exec { 'remove NFS client packages':
                command => "/usr/bin/yum -y remove \
                rpcbind \
                nfs-utils \
                nfs-utils-lib",
                onlyif => "/bin/rpm -q \
                rpcbind \
                nfs-utils \
                nfs-utils-lib",
            }
        }
        /5\..*/: {
            package {
                "portmap": ensure => absent;
                "ypbind": ensure => absent;
                "nfs-utils": ensure => absent;
            }
        }
        default: { unimplemented() }
    }
}
