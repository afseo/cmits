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
Puppet::Parser::Functions::newfunction(:unimplemented,
        :doc => "Complain that something is unimplemented on a certain OS and release. If you supply any strings as arguments, they are included in the error message.") do |vals|
    vals = vals.collect { |s| s.to_s }.join(" ") if vals.is_a? Array
    os = lookupvar('operatingsystem')
    ver = lookupvar('operatingsystemrelease')
    message = "Unimplemented on #{os} release #{ver}"
    if vals != ""
        message << ": #{vals}"
    end
    function_crit [message]
    fail "#{scope_path[0].to_s}: #{message}"
end

