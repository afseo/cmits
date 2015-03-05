# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
require 'puppet'

Puppet::Type.newtype(:mac_automount) do
    @doc = <<-EOT
        Manage NFS automounts on Macs.

        On a Mac, NFS automounts are configured as items in the Open Directory
        under /NFS.

        Example:
        
            mac_automount { '/net/bla':
                source => 'nfsfiler.example.com:/vol/bla',
                options => ['nodev', 'nosuid'],
                ensure => present,
            }
    EOT

    ensurable do
        defaultvalues
        defaultto :present
    end

    newparam(:mountpoint) do
        desc "The absolute path in the filesystem where the NFS mount will appear."
        isnamevar
        isrequired
        newvalues /^\/.*$/
    end

    newparam(:source) do
        desc "The source of the NFS mount."
        isrequired
    end

    newparam(:options) do
        desc "The options with which to do the mount. See mount(8)."
        munge do |value|
            if value.is_a? Array
                value.flatten
            else
                [value]
            end
        end
    end
end
