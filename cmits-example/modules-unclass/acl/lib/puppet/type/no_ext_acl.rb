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
Puppet::Type.newtype(:no_ext_acl) do
    @doc = "Make sure a file or directory has no extended ACL. There is no
support for setting the extended ACL here, only removing the whole thing.
Example usage:

    no_ext_acl { '/etc/ntp.conf': }
"
    ensurable do
        defaultvalues
        defaultto :present
    end
    newparam(:name) do
        desc "Name of the file or directory."
    end
    newparam(:recurse) do
        desc "Whether to recurse into children of a directory. (There is no provision for a recurselimit other than infinity.)"
        newvalues :true, :false
        defaultto :false
    end

end
