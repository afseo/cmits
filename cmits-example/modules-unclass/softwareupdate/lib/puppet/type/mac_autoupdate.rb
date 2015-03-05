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

Puppet::Type.newtype(:mac_autoupdate) do
    @doc = <<-EOT
    Turn on and off automatic software updating on Macs.

    There can only be one of this resource in the manifest.
    EOT
    newparam(:name) do
        desc 'This must always be "auto".'
        newvalues "auto"
    end
    newproperty(:enabled) do
        desc "Whether automatic software updates should be enabled."
        newvalues :true, :false
        isrequired
    end
    validate do
        if not [:true, :false].include?(self[:enabled])
            fail "You must provide a true or false value for the enabled parameter"
        end
    end
end
