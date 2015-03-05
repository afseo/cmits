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
require 'index_haoha'
require 'puppet/provider/plist_osx_cocoa_common'

# if we can't get the thing we need, we can't provide anything. but we don't
# want the whole Puppet agent to die because of the problem, so we have to
# catch the exception.
begin
    require 'osx/cocoa'
rescue LoadError
    # OSX won't be defined, and the confine below will fail, marking the
    # provider unsuitable.
end



Puppet::Type.type(:mac_plist_value).provide :osx_cocoa do
    desc "Manage property list values on a Mac by using the Cocoa extensions to Ruby."

    confine :operatingsystem => :darwin
    defaultfor :operatingsystem => :darwin
    confine :true => Object.constants.include?('OSX')

    def _load
        fail "could not open plist file #{resource[:file].inspect}" \
            unless File.readable? resource[:file]
        plist = OSX::NSDictionary.dictionaryWithContentsOfFile(
                resource[:file])
        plist ||= OSX::NSDictionary.dictionary
        v = plist.to_ruby
        debug v.inspect
        v
    end

    def _save properties
        debug "new value of all properties: #{properties.inspect}"
        # We should write another file and move it over this one, but this
        # way we don't have to worry with ownership and permissions.  And
        # plist files should be short enough that we can write them in one
        # or two system calls, so our failure window is small.
        File.open(resource[:file], 'w') do |f|
            f.print properties.to_plist
        end
    end

    include PlistOSXCocoaCommon

end
