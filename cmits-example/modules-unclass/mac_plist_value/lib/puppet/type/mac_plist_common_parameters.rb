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
Mac_plist_common_parameters = Proc.new do
    ensurable do
        defaultvalues
        defaultto :present
    end

    newparam(:key) do
        desc <<-EOT
            The preference key within the file.
            
            Multiple values for the key parameter, or slash-separated path
            elements after the colon in the resource name, are treated as keys
            to nested dictionaries; so
        
                key => ['key', 'key2']
        
            assumes that we are editing a property list that's already shaped
            like this:

                { "key" => { "key2" => 8 } }

            Multiple values are used as keys in successive depths of
            dictionaries.

            Keys with slashes in their names are not supported. (On a Snow
            Leopard Mac in 2013, 19 of the 1720 property names I could find had
            slashes, about 1.1%.)

            If one of the values of the key is '*', multiple values may be set
            or deleted, one for each possible key at that level of the property
            list.
        EOT

        isnamevar
        isrequired
        newvalues /^[^:\/].*/
        munge do |value|
            value = [value] unless value.is_a?(Array)
            value
        end
    end

    newparam(:value) do
        desc <<-EOT
            The intended value for the given key in the given property list
            file.

            Values may be coerced to whatever they look like, so true and false
            will end up as booleans, values comprised entirely of digits will
            likely end up as integers, etc.

            Puppet treats arrays containing a single value specially (see
            http://projects.puppetlabs.com/issues/15813), so to specify a value
            which should be an array and should contain one thing, add an empty
            string to the end of the array. Like
            
                value => ['thing i wanted', '']

            The empty string will be stripped off at the proper time. If you
            find yourself in the unlikely case of needing an empty string at
            the end of an array value, simply give two empty strings. Like

                value => ['next is an empty', '', '']

            The last empty string will be stripped off, but the second-to-last
            will remain.

        EOT

        # Default to something that's not nil, so ensure => absent will work. I
        # forgot exactly how it works, but when parameters have nil values,
        # that means something to Puppet besides "this parameter's value is
        # nil," like "meh, don't bother to do anything" or something.
        defaultto :true
        munge do |v|
            case v
            when :true; true
            when :false; false
            else v
            end
        end
    end
end
