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
require 'tempfile'
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


Puppet::Type.type(:mac_mcx_plist_value).provide :osx_cocoa_dscl do
    desc <<-EOT
    Manage property list values in a directory service on a Mac by using the
    Cocoa extensions to Ruby and the dscl utility.
    EOT

    confine :operatingsystem => :darwin
    defaultfor :operatingsystem => :darwin
    confine :true => Object.constants.include?('OSX')
    commands :dscl => '/usr/bin/dscl'

    def _load
        # we don't want to try to parse errors as output
        out = execute(['/usr/bin/dscl', '/Local/Default', '-mcxexport',
                      resource[:record]], :combine => false)
        # The NSDictionary can't load a dictionary from a string with XML in
        # it, so we have to write a file. Ho, hum.
        rv = nil
        Tempfile.open('mcxplvosxcd') do |f|
            f.write(out)
            f.fsync
            plist = OSX::NSDictionary.dictionaryWithContentsOfFile(f.path)
            plist ||= OSX::NSDictionary.dictionary
            rv = plist.to_ruby
        end
        rv
    end

    def _save properties
        debug "new value of all properties: #{properties.inspect}"
        # We should write another file and move it over this one, but this
        # way we don't have to worry with ownership and permissions.  And
        # plist files should be short enough that we can write them in one
        # or two system calls, so our failure window is small.
        Tempfile.open('mcxplvosxcd') do |f|
            f.print properties.to_plist
            f.fsync
            dscl '/Local/Default', '-mcximport', resource[:record], f.path
        end
    end

    def _one_exists? is
        is and \
            (is['value'] == _coerce(resource[:value])) and \
            (is['state'] == resource[:mcx_domain].to_s)
    end

    def _create_one place_to_set, last_key
        place_to_set[last_key] = {
            'state' => resource[:mcx_domain].to_s,
            'value' => _coerce(resource[:value])
        }
        debug "set value of #{resource[:key].inspect} " \
              "to #{place_to_set[last_key].inspect}"
    end

    include PlistOSXCocoaCommon
end
