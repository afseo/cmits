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

Puppet::Type.newtype(:global_pwpolicy) do
    @doc = "Deal with global password policy on Macs.
    Example:

        global_pwpolicy { 'usingHistory': value => 15 }
    
    Changing password policy on a remote host is not supported by this type.
    "
    newparam(:name) do
        desc "The name of a global password policy parameter, written in camelCase, just as listed in pwpolicy(8)."
        isnamevar
    end

    newproperty(:value) do
        desc "The value of the global password policy item named by the name parameter.
        Some password policy values are either 0 or 1. You can specify true or
        false for these if you like. Some password policy values are dates.
        These you must specify as a string, 'mm/dd/yy', the same format that
        the pwpolicy utility expects."
    end
end
