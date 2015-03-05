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

Puppet::Type.type(:mac_autoupdate).provide :softwareupdate do
    desc "Manage automatic updates on a Mac using the softwareupdate command."

    commands :softwareupdate => "/usr/sbin/softwareupdate"
    confine :operatingsystem => :darwin
    defaultfor :operatingsystem => :darwin

    def enabled
        out = softwareupdate '--schedule'
        case out
        when "Automatic check is off\n"
            return :false
        when "Automatic check is on\n"
            return :true
        else
            fail "Unrecognized output from " \
                 "softwareupdate --schedule: #{out.inspect}"
        end
    end

    def enabled= newvalue
        case newvalue
        when :true
            softwareupdate '--schedule', 'on'
        when :false
            softwareupdate '--schedule', 'off'
        # else ... eh, do nothing
        end
    end
end
