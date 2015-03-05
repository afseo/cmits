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
# \subsection{Gluster with Automount}
#
# As of 3.6.0.29-2.el6, \verb!glusterfs! when used with automount
# fails to mount the requested filesystem. If you turn up the
# debugging on autofs enough, you find this error:
#
# \begin{verbatim}
# /sbin/mount.glusterfs: line 13: /dev/stderr: Permission denied
# \end{verbatim}
#
# This boils down to an AVC denial. An SELinux module that allows the
# required behavior is provided here. Include the class to install the
# SELinux module.

class gluster::automount {
    require ::automount
    $selmoduledir = "/usr/share/selinux/targeted"
    file { "${selmoduledir}/gluster_automount.pp":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/gluster/\
gluster_automount.selinux.pp",
    }
    selmodule { "gluster_automount":
       ensure => present,
       syncversion => true,
       notify => Service['autofs'],
    }
}
