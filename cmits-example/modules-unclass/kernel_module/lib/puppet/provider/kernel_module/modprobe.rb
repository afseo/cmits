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

Puppet::Type.type(:kernel_module).provide :modprobe do
    desc "Remove extended ACLs using modprobe."

    commands :modprobe => "/sbin/modprobe"
    commands :lsmod => "/sbin/lsmod"

    def lsmod
        self.debug "Listing loaded kernel modules"
        stdin, stdout, stderr = Open3.popen3(command(:lsmod))
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        raise Puppet::Error, err unless err.empty?
        lines = out.split("\n")
        unless lines.length > 1
            raise Puppet::Error, "unexpectedly short lsmod output" 
        end
        # [1..-1]: discard first (header) line
        words = lines[1..-1].map {|x| x.split}
        # we are only interested in the list of loaded modules - not in their
        # sizes or dependencies
        return words.map {|x| x[0]}
    end

    def exists?
        return lsmod.member? @resource[:name]
    end

    def destroy
        self.debug "Attempting to unload kernel module"
        stdin, stdout, stderr = Open3.popen3(
            command(:modprobe), '-r', @resource[:name])
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        raise Puppet::Error, err unless err.empty?
    end

    def create
        self.debug "Attempting to load kernel module"
        stdin, stdout, stderr = Open3.popen3(
            command(:modprobe), @resource[:name])
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        raise Puppet::Error, err unless err.empty?
    end
end
