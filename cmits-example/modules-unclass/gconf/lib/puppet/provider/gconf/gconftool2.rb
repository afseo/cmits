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

Puppet::Type.type(:gconf).provide :gconftool2 do
    desc "Set and unset keys in gconf, the glib configuration system"

    commands :gconftool2 => "/usr/bin/gconftool-2"

    def _gconftool2 *args
        params = [
            '--direct',
            '--config-source', "xml:readwrite:#{@resource[:config_source]}",
            *args]
        # umask: make sure anyone can read this systemwide setting we
        # are setting.
        self.debug "Running gconftool-2 #{params.join(' ')} with umask 022"
        existing_umask = File.umask(0022)
        stdin, stdout, stderr = Open3.popen3(command(:gconftool2), *params)
        File.umask(existing_umask)
        stdin.close
        out = stdout.read.chomp
        stdout.close
        err = stderr.read.chomp
        stderr.close
        errlines = err.split("\n")
        novalue = errlines.detect {|x| x =~ /^No value set/} ? true : false
        errlines.reject! {|x| x =~ /^No value set/}
        err = errlines.join("\n")
      
        raise Puppet::Error, err unless err.empty?
        return [novalue, out]
    end

    def exists?
        novalue, out = _gconftool2('--get', @resource[:path])
        if novalue
            self.debug "No value"
            return nil
        elsif (out == @resource[:value])
            return true
        else
            self.debug "Should be #{@resource[:value]}; is #{out}"
            return false
        end
    end

    def destroy
        novalue, out = _gconftool2('--unset', @resource[:path])
    end

    def create
        if @resource[:type].nil?
            raise Puppet::Error, "No type given for value to be set in gconf"
        end
        novalue, out = _gconftool2('--set', @resource[:path],
                                   @resource[:value],
                                   '--type', @resource[:type])
    end
end
