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
require 'puppet/type/mac_plist_common_parameters'

Puppet::Type.newtype(:mac_plist_value) do
    @doc = <<-EOT
        Edit property lists in files on the Mac.

        If the name of the file to edit contains a colon, you must specify it
        using the file parameter, not the title of the resource.

        The file must exist, even if it is empty. You may need to use a file
        resource to make sure the file will exist. This is so that you can be
        sure of the ownership and permissions of a property list file that you
        may be creating.

        Examples:
        
            mac_plist_value { 'meaningless unique name with no colons':
                file => '/path/to/settings.plist',
                key => ['key', 'key2'],
                value => 3,
            }
            mac_plist_value { '/path/to/settings.plist:key/key2':
                value => 3,
            }
            mac_plist_value { '/path/to/settings.plist:key/key2':
                ensure => absent,
            }
            mac_plist_value { '/path/to/settings.plist:key':
                value => { 'key2' => 3, },
            }
            mac_plist_value { '/path/to/a.plist:key/*/otherkey':
                value => 3,
            }
            mac_plist_value { 'meaningless unique name w/o colons':
                file => '/path/to/a.plist',
                key => ['key', '*', 'otherkey'],
                value => 3,
            }
    EOT

    def self.title_patterns
        [
            [/^([^:]+):(.+)$/, [
                [ :file, lambda {|x| x} ],
                [ :key,  lambda {|x| x.split('/') } ]]],
            [/^.*$/, []]]
    end

    newparam(:file) do
        desc "The absolute path of a property list file."
        isnamevar
        isrequired
        newvalues /^\/[^:]*$/
    end

    autorequire(:file) do
        [self[:file]]
    end


    instance_eval &Mac_plist_common_parameters


end
