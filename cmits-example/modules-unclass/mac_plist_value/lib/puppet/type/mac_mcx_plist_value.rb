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

Puppet::Type.newtype(:mac_mcx_plist_value) do
    @doc = <<-EOT
        Set things in property lists stored in the Mac directory service.

        Examples:
        
            mac_mcx_plist_value { 'meaningless but unique name':
                record => '/Computers/host1.example.com',
                key => ['com.example.app', 'mount-controls', 'dvd'],
                mcx_domain => 'always',
                value => { 'zap-sound' => 'blat' },
            }
            mac_mcx_plist_value { "/Computers/host1.example.com:\
                    com.example.app/mount-controls/dvd":
                value => 3,
            }
            mac_mcx_plist_value { 'meaningless unique 2':
                record => '/Computers/host1.example.com',
                key => ['com.example.app', 'mount-controls', 'dvd', 1],
                ensure => absent,
            }
        
    EOT

    def self.title_patterns
        [
            [/^([^:]+):(.+)$/, [
                [ :record, lambda {|x| x} ],
                [ :key,  lambda {|x| x.split('/') } ]]],
            [/^.*$/, []]]
    end

    newparam(:record) do
        desc "The absolute path of a record in the directory service."
        isnamevar
        isrequired
        newvalues /^\/[^:]*$/
    end

    newparam(:mcx_domain) do
        desc <<-EOT
        The type of management applied to the key.

        While dscl allows the "none" MCX domain, we do not here: use ensure =>
        absent instead.
        EOT
        newvalues :always, :once, :often, :unset
        defaultto :always
    end


    instance_eval &Mac_plist_common_parameters


end
