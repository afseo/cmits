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

Puppet::Type.newtype(:mac_authz_plist_value) do
    @doc = <<-EOT
        Set things in property lists stored in the authorization database.

        Examples:
        
            mac_authz_plist_value { 'meaningless but unique name':
                right => 'system.preferences',
                key => 'shared',
                value => false,
            }
            mac_authz_plist_value { 'system.preferences:shared':
                value => false,
            }
            mac_authz_plist_value { 'meaningless but unique 2':
                right => 'system.login.screensaver',
                key => rule,
                value => ['authenticate-session-owner', ''],
            }
            mac_authz_plist_value { 'system.login.screensaver:rule':
                value => ['authenticate-session-owner', ''],
            }
        
    EOT

    def self.title_patterns
        [
            [/^([^:]+):(.+)$/, [
                [ :right, lambda {|x| x} ],
                [ :key,  lambda {|x| x.split('/') } ]]],
            [/^.*$/, []]]
    end

    newparam(:right) do
        desc "The name of a right in the system authorization database."
        isnamevar
        isrequired
        newvalues /^[^:]*$/
    end

    instance_eval &Mac_plist_common_parameters


end
