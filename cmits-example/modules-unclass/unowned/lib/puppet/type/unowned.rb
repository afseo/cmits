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
#
# ... much is owed to the File resource type of Puppet 2.7.20

Puppet::Type.newtype(:unowned) do
    @doc = <<-EOT
        Fix 'unowned' files and directories, that is, those which are not owned
        by a known user or are not group-owned by a known group.

        Example:
        
            unowned { '/usr/sbin':
                recurse => true,
                owner => root,
                group => root
            }

        CAVEAT: This does not integrate with the file type. For example, if you
        write:

            file { '/tmp/foo': owner => 4832, }
            unowned { '/tmp/foo': recurse => false, owner => root }

        and 4832 is not a uid belonging to a known user, the file and unowned
        resources will undo each other's work.

        NOTE: this type is intended for policing unowned system files on local
        hard drives, which are normally owned by bog-standard system users like
        root. If you have system files owned by users who can disappear, e.g.,
        when you lose a connection to an LDAP server, such files could be
        counted unowned by this resource type during the failure, and chowned
        accordingly.
    EOT

    newparam(:path) do
        desc "The path whose non-unownership we are to establish."
        isnamevar
        validate do |value|
            unless Puppet::Util.absolute_path?(value)
                fail Puppet::Error, "File paths must be fully qualified, not '#{value}'"
            end
        end
        munge do |value|
            ::File.expand_path(value)
        end
    end
    
    newparam(:recurse) do
        desc "Whether to recurse into subdirectories of the given path looking for 'unowned' files."
        newvalues :true, :false
        defaultto :false
        munge do |value|
            case value
            when true, :true; true
            when false, :false; false
            end
        end
    end

    newparam(:recurselimit) do
        desc "How deeply to recurse into subdirectories looking for 'unowned' files."
        newvalues /^[0-9]+$/
        munge do |value|
            newval = super(value)
            case newval
            when Integer, Fixnum, Bignum; value
            when /^\d+$/; Integer(value)
            else
              self.fail "Invalid recurselimit value #{value.inspect}"
            end
        end
    end

    newproperty(:owner) do
        desc "The user who should own any files found to be 'unowned.' Default is root."
        defaultto 'root'

        munge do |value|
            if value =~ /^\d+$/
                value.to_i
            else
                value
            end
        end

        def insync?(current)
            # We don't want to validate/munge users until we actually start to
            # evaluate this property, because they might be added during the
            # catalog apply.
            @should.map! do |val|
              provider.name2uid(val) or raise "Could not find user #{val}"
            end

            provider.owned_by_known_user
        end
    end

    newproperty(:group) do
        desc "The group which should group-own any files found to be 'unowned.' Default is 0."
        defaultto 0

        munge do |value|
            if value =~ /^\d+$/
                value.to_i
            else
                value
            end
        end

        def insync?(current)
            # We don't want to validate/munge users until we actually start to
            # evaluate this property, because they might be added during the
            # catalog apply.
            @should.map! do |val|
              provider.name2gid(val) or raise "Could not find user #{val}"
            end

            provider.groupowned_by_known_group
        end
    end

    autorequire(:user) do
        if @parameters.include? :owner
            what_was_written = self[:owner]
            if what_was_written.is_a?(Integer) or what_was_written =~ /^\d+$/
                nil
            else
                what_was_written
            end
        end
    end

    validate do
        self.warning "Possible error: recurselimit is set but not recurse, no recursion will happen" if !self[:recurse] and self[:recurselimit]
    end

    def recurse?
        self[:recurse] == true
    end

    def eval_generate
        if self[:recurse]
            result = []
            metadatas = Puppet::FileServing::Metadata.indirection.search(
                self[:path],
                :recurse => self[:recurse],
                :recurselimit => self[:recurselimit],
                :checksum_type => :none
            )
            metadatas.each do |meta|
                next meta if meta.relative_path == '.'
                result << newchild(meta.relative_path)
            end
            result
        else
            []
        end
    end

    def newchild(path)
        full_path = ::File.join(self[:path], path)
        options = @original_parameters.merge(:path => full_path)
        options.reject! {|param, value| value.nil? }
        [:recurse, :recurselimit].each do |param|
            options.delete(param) if options.include?(param)
        end
        self.class.new(options)
    end
end
