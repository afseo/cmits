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

Puppet::Type.type(:nss_cert).provide :certutil do
    desc "Manage certificates in an NSS database using certutil from nss-utils."

    commands :certutil => "/usr/bin/certutil"

    def dbsplit
        n = @resource[:name]
        dbdir = n.split(':')[0]
        # if nickname has colon in it, don't barf
        nickname = n.split(':')[1..-1].join(':')
        if @resource[:sqlite] == :true
            dbdir = 'sql:' + dbdir
        end
        return [dbdir, nickname]
    end

    # assumption: input is short enough to fit down a pipe without blocking
    def _certutil *params, &input
        dbdir, nickname = dbsplit
        params += ['-d', dbdir, '-n', nickname]
        pwf = @resource[:pwfile]
        params += ['-f', pwf] unless pwf.nil? or pwf.empty?
        self.debug "Running #{command(:certutil).inspect} " \
                   "#{params.map {|x| x.inspect}.join(' ')}"
        stdin, stdout, stderr = Open3.popen3(command(:certutil), *params)
        yield stdin if block_given?
        stdin.close
        out = stdout.read
        stdout.close
        err = stderr.read
        stderr.close
        return out, err
    end


    def exists?
        out, err = _certutil('-L')
        if err.include? 'Could not find cert'
            self.debug "Certificate absent"
            return nil
        end
        raise Puppet::Error, err unless err.empty?
        self.debug "Certificate present"
        return :true
    end

    def destroy
        self.debug "Deleting certificate"
        out, err = _certutil('-D')
        raise Puppet::Error, err unless err.empty?
    end

    def create
        raise Puppet::Error, "Cannot install cert: no source given" unless
            @resource.parameter(:source)
        self.debug "Installing certificate " \
                   "with trustargs #{@resource[:trustargs].inspect}"
        out, err = _certutil('-A', '-t', @resource[:trustargs]) {|stdin|
            stdin.puts @resource.parameter(:source).content
        }
        raise Puppet::Error, err unless err.empty?
    end
end
