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
# \subsection{Disable NFS client}
#
# This class disables services that are needed both for NFS servers
# and for NFS clients.
#
# If you need your Macs to be NFS clients, do not include this class.

class nfs::client::no::darwin {
# \implements{mlionstig}{OSX8-00-00142}%
# Disable the NFS lock d\ae mon.
    service { 'com.apple.lockd':
        enable => false,
        ensure => stopped,
    }
# \implements{mlionstig}{OSX8-00-00143}%
# Disable the NFS stat d\ae mon.
    service { 'com.apple.statd':
        enable => false,
        ensure => stopped,
    }
}
