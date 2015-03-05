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

Puppet::Type.type(:trac_permission).provide :trac_admin do
    desc <<-EOT
    
    Manage permissions in a Trac instance using the trac-admin command.

    There is a hardcoded assumption that all Trac instances live under
    /var/www/tracs, so that you can use puppet resource list to find the
    complete present configuration.

    Furthermore we assume when parsing the Trac permissions that actions do not
    contain spaces, but subjects may.

    EOT

    commands :trac_admin => "/usr/bin/trac-admin"

    # There was once code here to try to fetch instances of this provider so
    # that `puppet resource` could show Trac permissions existing on the
    # system; but that didn't work, and this parsing code is all that's still
    # needed to make the resource get and set Trac permissions.
    class << self
        def permissions_in instance_dir
            found = []
            out = trac_admin instance_dir, 'permission', 'list'
            lines = out.split("\n")
            # skip header
            lines[3..-1].each do |line|
                break if line == ""    # end of the permission table
                values = line.split
                if values.length > 1
                    action = values[-1]
                    subject = values[0..-2].join(' ')
                    found << [subject, action]
                else
                    warning "in Trac instance #{instance_dir}, " \
                            "cannot understand permission line " \
                            "#{line.inspect}"
                end
            end
            found
        end
    end

    def permissions_in instance_dir
        self.class.permissions_in instance_dir
    end

    def cartesian a, b
        # In Ruby 1.9, Arrays have a product method. But we may not be running
        # in Ruby 1.9.
        result = []
        a.each do |from_a|
            b.each do |from_b|
                result << [from_a, from_b]
            end
        end
        result
    end

    def needs_done
        all_users = permissions_in @resource[:instance]
        is = all_users.select {|s, a| @resource[:subject].include? s}
        should = cartesian(@resource[:subject], @resource[:action])
        to_add = should - is
        to_remove = is & should
        [to_add, to_remove]
    end

    def exists?
        to_add, to_remove = needs_done
        debug "to add: #{to_add.inspect}"
        debug "to remove: #{to_remove.inspect}"
        if @resource.deleting?
            to_remove.any?
        else
            to_add.empty?
        end
    end

    def create
        to_add, to_remove = needs_done
        to_add.each do |s, a|
            trac_admin @resource[:instance], 'permission', 'add', s, a
        end
    end

    def destroy
        to_add, to_remove = needs_done
        to_remove.each do |s, a|
            trac_admin @resource[:instance], 'permission', 'remove', s, a
        end
    end
end
