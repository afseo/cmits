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

Puppet::Type.type(:no_ext_acl).provide :getsetfacl do
    desc "Remove extended ACLs using the getfacl and setfacl tools."

    commands :getfacl => "/usr/bin/getfacl"
    commands :setfacl => "/usr/bin/setfacl"

    # Here's a weird thing: a resource of this type exists if the extended ACL
    # for the given file DOES NOT exist. So the sense of exists? is the
    # opposite of what you would expect; the create method actually destroys
    # the extended ACL; and the destroy method would un-destroy it, but what
    # would you set it to? What are the contents of /dev/null?

    def exists?
        self.debug "Getting extended ACL"
        if not FileTest.exists? @resource[:name]
            # well, if it doesn't exist, it can't very well have an extended
            # ACL...
            self.debug "Does not exist => has no ACL; resource is present"
            return true
        end
        params = [command(:getfacl)]
        params << '-R' if @resource[:recurse]
        # -s: "Skip files that only have the base ACL entries (owner, group,
        # others)."
        params << '-s'
        params << @resource[:name]
        stdin, stdout, stderr = Open3.popen3(*params)
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        # If you pass in an absolute pathname, it will say, "Removing leading
        # '/' from absolute path names", on stderr. We want to ignore that
        # error.
        err = err.split('\n').reject {|x| x =~ /Removing leading '\/'/}.join('\n')
        # Now, if it said anything else on stderr, fail.
        raise Puppet::Error, err if not err.empty?
        if out.empty?
            self.debug "No extended ACL; resource is present"
            return true
        else
            self.debug "Has an extended ACL; resource is absent"
            return false
        end
    end

    def destroy
        raise Puppet::Error, "Cannot destroy a lack of an extended ACL"
    end

    def create
        self.debug "Deleting extended ACL and default ACL (if any)"
        params = [command(:setfacl)]
        params << '-R' if @resource[:recurse]
        # -b: remove all extended ACL entries
        params << '-b'
        # -k: remove default ACL (for dirs)
        params << '-k'
        params << @resource[:name]
        stdin, stdout, stderr = Open3.popen3(*params)
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        raise Puppet::Error, err if not err.empty?
    end
end
