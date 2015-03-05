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
Puppet::Type.newtype(:gconf) do
    @doc = "Apply a gconf setting.
"

    ensurable do
        defaultvalues
        defaultto :present
    end
    newparam(:config_source) do
        desc "The GConf 'configuration source' to use. Valid values are
defaults, mandatory or system, or a path to a configuration source
(e.g., '/var/lib/gdm/.gconf'). Default value for this parameter is mandatory."
        newvalues(:defaults, :mandatory, :system, /\/.+/)
        defaultto :mandatory
        munge do |value|
            value = value.to_s
            case value
                when "defaults"  then "/etc/gconf/gconf.xml.defaults"
                when "mandatory" then "/etc/gconf/gconf.xml.mandatory"
                when "system"    then "/etc/gconf/gconf.xml.system"
                else value
            end
        end
    end

    newparam(:path, :namevar => true) do
        desc "The path within the GConf configuration source."
    end

    newparam(:type) do
        isrequired
        desc "The type of the value which should be at the path. Valid values are int, bool, float, and string. List and pair are not supported at this time."
        newvalues(:int, :bool, :float, :string)
        munge do |value|
            value.nil? ? nil : value.to_s
        end
    end

    newparam(:value) do
        desc "The value which should be at the given path in the configuration
source."

        # If the user sets value to something which is a nil value, like false,
        # we need should to still return something non-nil, otherwise Puppet's
        # machinery gets angry. Since we're likely getting the present value
        # ("is", I suppose) as a string, and we're likely passing the value to
        # be set ("should") as a string, we lose no important knowledge by
        # discarding the type of should.
        munge do |value|
            value.to_s
        end

        # Show the type of gconf values in their to_s.

        def is_to_s x
            "(#{@resource[:type]}) #{x}"
        end

        def should_to_s x
            "(#{@resource[:type]}) #{x}"
        end
    end
end
