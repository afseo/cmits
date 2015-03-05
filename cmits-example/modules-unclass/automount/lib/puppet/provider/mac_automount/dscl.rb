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

Puppet::Type.type(:mac_automount).provide :dscl do
    desc "Manage automounts on a Mac using the dscl command."

    commands :dscl => "/usr/bin/dscl"
    confine :operatingsystem => :darwin
    confine :true => (execute(['dscl', '/Local/Default', '-list', '/NFS'], :failonfail => false) !~ /^list: Invalid Path$/m)
    defaultfor :operatingsystem => :darwin

    @parsed_NFS = {}

    # When we toss this onto our volume mount sources in the DSCL, it
    # will show up as nfs://DONT_EDIT_WITH_GUI_myserver/myshare.
    # Muahaha.
    def colon_nonce; 'DONT_EDIT_WITH_GUI_:'; end

    class << self
        attr_accessor :parsed_NFS
        
        def prefetch(resources)
            self.populate_parsed_NFS
        end

        def instances
#            debug 'instances!'
            if self.parsed_NFS == {}
                self.prefetch(nil)
            end
            _instances = []
            self.parsed_NFS.each do |k,v|
                # reject malformed entries
                if v.has_key?('VFSLinkDir') and v.has_key?('RecordName') \
                        and v.has_key?('VFSOpts')
                    un_nonced = v['RecordName'][colon_nonce.length..-1]
                    _instances << new(:name => v['VFSLinkDir'],
                            :source => un_nonced,
                            :options => (v['VFSOpts'] || '').split(','))
                end
            end
#            debug "instances are #{_instances.inspect}"
            _instances
        end

        def populate_parsed_NFS
            the_command = ['dscl', '/Local/Default', '-readall', '/NFS']
            out = execute(the_command,
                          :combine => false)
            if out =~ /^readall: /
              # this is not output, it's an error on stdout
              fail "execution of #{the_command.inspect} failed; it said this on stdout: #{out.inspect}"
            end
            items = out.split("-\n")
            # We are parsing the output of dscl. It's possible instead to tell
            # dscl '-plist' and use a plist parser to do this. That's probably
            # better, but I couldn't figure out how to do it without
            # introducing a dependency on another package.
            items.each do |it|
#                debug "item: #{it.inspect}"
                kv = {}
                last_key = nil
                last_value = ''
                it.split("\n").each do |line|
                    if line.start_with? ' '
                        # continuation
                        last_value += line.lstrip
                    else
                        # store continuation from previous iteration
                        kv[last_key] = last_value if not last_key.nil?
                        last_key, last_value = line.split(':', 2).collect {|x| x.strip}
                    end
                end
                # store continuation from final iteration
                kv[last_key] = last_value if not last_key.nil?
#                debug "resulting kv: #{kv.inspect}"
                @parsed_NFS[kv['RecordName']] = kv
            end
        end
    end

    # "standard required provider instance methods"
    def initialize(resource)
        if self.class.parsed_NFS == {}
            self.class.prefetch(resource)
        end
        super
    end

    def exists?
        self.class.prefetch(self)
        debug "resource's name is #{@resource[:name].inspect}"
        relevant = self.class.parsed_NFS.find {|k,v| v['VFSLinkDir'] == @resource[:name]}
        debug "relevant parsed_NFS is #{(relevant || {}).inspect}"
        if relevant.nil?
          false
        else
          from, info = relevant
          debug "existing mount is from #{from}; resource source is #{@resource[:source]}"
          return ((from == colon_nonce + @resource[:source]) and
                  (info['VFSType'] == 'NFS') and
                  (info['VFSOpts'].split(',') == @resource[:options]))
        end
    end

    def create
        # maybe we have the wrong thing. destroy first
        destroy
        # Backslash-escape slashes in the source, so dscl doesn't
        # think foo:/bar/baz means the baz item inside the bar folder
        # inside the foo: folder, and say "Invalid path."
        #
        # In October 2014, NFS war was beginning. What happen?
        # Somebody set up us the new filer... How are you gentlemen!!
        # All your base are belong to us. - Turning up the verbosity
        # of the autofsd and automountd seems to indicate that the
        # string before the first colon is stripped off before the
        # automounter runs mount_NFS, with the result that it gets
        # called like mount_NFS /vol/shareiwant /net/shareiwant,
        # instead of mount_NFS hostwhereitis:/vol/shareiwant
        # /net/shareiwant. So we toss something on the beginning.
        node_being_created = "/NFS/#{colon_nonce}#{@resource[:source].gsub('/','\\/')}"
        # Caveat: dscl will only create one attribute at a time;
        # additional arguments are treated as multiple values for the
        # attribute, not more attributes each with its own value.
        dscl '/Local/Default', '-create', node_being_created,
            'VFSLinkDir', @resource[:mountpoint]
        dscl '/Local/Default', '-create', node_being_created,
            'VFSOpts', @resource[:options].join(',')
        dscl '/Local/Default', '-create', node_being_created,
            'VFSType', 'NFS'
    end

    def destroy
      # if an entry exists which is right but doesn't have the colon
      # nonce, we want to remove it
      to_delete = self.class.parsed_NFS.find_all {|k,v| 
        debug "k #{k.inspect} v #{v.inspect}"
        (v['VFSLinkDir'] == @resource[:name]) || 
        (k == @resource[:source]) || 
        (k[(colon_nonce.length+1)..-1] == @resource[:source])}
      to_delete.each do |from, info|
        begin
          backslashies = from.gsub("/") {|x| "\\/" }
          execute(['dscl', '/Local/Default', '-delete', 
                   "/NFS/#{backslashies}"],
                  :failonfail => false, :combine => true)
        rescue Puppet::ExecutionFailure => e
          # if dscl can't find the node we were trying to delete, well
          # that's fine
          debug "dscl execution failed, with exception #{e.inspect}"
          raise unless e.message =~ '\(eDSUnknownNodeName\)'
        end
      end
    end

    def options
        ["foo"]
    end

#    def value
#        self.class.parsed_NFS[name]
#    end
#
#    def value= newvalue
#        string_value = newvalue
#        if PolicyItemTypes[name] == :bool
#            int_value = [:false, :true].index(newvalue.to_i) || 0
#            string_value = int_value.to_s
#        end
#        pwpolicy '-setglobalpolicy', "#{name}=#{string_value}"
#    end

end
