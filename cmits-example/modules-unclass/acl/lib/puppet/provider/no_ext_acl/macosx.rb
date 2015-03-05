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
require 'open3'

Puppet::Type.type(:no_ext_acl).provide :macosx do
    desc "Remove extended ACLs using chmod, as under Mac OS X."

    commands :ls => "/bin/ls"
    commands :chmod => "/bin/chmod"
    confine :operatingsystem => :darwin
    defaultfor :operatingsystem => :darwin

    # See http://stackoverflow.com/questions/5387741
    def exists?
        output = execute [:ls, '-led', @resource[:name]], :combine => false
        # file with no ACL:
        # -rw-r--r--  1 jared  wheel  0 Feb  6 12:00 /tmp/bar
        # file with an ACL:
        # -rw-r--r--+ 1 jared  wheel  0 Feb  6 11:59 /tmp/foo
        return ! output.split('\n').grep(/^..........\+/).any?
    end

    def destroy
        raise Puppet::Error, "Cannot destroy a lack of an extended ACL"
    end

    def create
        debug "Deleting extended ACL and default ACL (if any)"
        if @resource[:recurse] == :true
            chmod '-R', '-N', @resource[:name]
        else
            chmod '-N', @resource[:name]
        end
    end
end
