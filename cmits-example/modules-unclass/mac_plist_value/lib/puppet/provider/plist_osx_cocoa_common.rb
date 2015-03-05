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

# if we can't get the thing we need, we can't provide anything. but we don't
# want the whole Puppet agent to die because of the problem, so we have to
# catch the exception.
begin
    require 'osx/cocoa'
rescue LoadError
    # OSX won't be defined, and the confine below will fail, marking the
    # provider unsuitable.
end


module PlistOSXCocoaCommon

    def _coerce value
        case value
        when /^[0-9]+$/; value.to_i
        when "true"; true
        when "false"; false
        when Array
            coerced = value.collect {|x| _coerce(x) }
            if coerced[-1] == ''
                coerced[0..-2]
            else
                coerced
            end
        when Hash
            pairs = value.to_a
            pairs.inject({}) {|h, (k,v)| h[k] = _coerce(v); h }
        else value
        end
    end

    def _one_exists? is
        is == _coerce(resource[:value])
    end

    def _create_one place_to_set, last_key
        place_to_set[last_key] = _coerce(resource[:value])
    end

    def exists?
        properties = _load
        rv = true
        begin
            index_haoha_or_fail properties, resource[:key] do |p|
                debug "present value of #{resource[:key].inspect} " \
                      "is #{p.inspect}"
                rv &&= _one_exists? p
            end
            rv
        rescue IndexError => e
            return false
        end
    end

    def create
        properties = _load
        last_key = resource[:key][-1]
        mkhashp properties, resource[:key][0..-2]
        index_haoha_or_fail properties, resource[:key][0..-2] do |place_to_set|
            _create_one place_to_set, last_key
        end
        _save properties
    end

    def destroy
        properties = _load
        last_key = resource[:key][-1]
        index_haoha_or_fail properties, resource[:key][0..-2] do |place_to_set|
            place_to_set.delete last_key
            debug "deleted last entry in path #{resource[:key].inspect}"
        end
        _save properties
    end
end
