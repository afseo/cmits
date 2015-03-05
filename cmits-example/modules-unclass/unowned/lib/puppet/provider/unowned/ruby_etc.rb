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

require 'etc'

Puppet::Type.type(:unowned).provide :ruby_etc do
    desc "Find 'unowned' files by using Ruby's Etc module, and fix them."

    # first hack, calls stat way too many times

    def owned_by_known_user
        stat = File.stat(@resource[:path])
        uid = stat.uid
        begin
            Etc.getpwuid uid
            true
        rescue ArgumentError
            # we do not know a name for this user
            false
        end
    end

    def groupowned_by_known_group
        stat = File.stat(@resource[:path])
        gid = stat.gid
        begin
            Etc.getgrgid gid
            true
        rescue ArgumentError
            # we do not know a name for this user
            false
        end
    end

    def name2uid name_or_number
        case name_or_number
        when Integer, Fixnum, Bignum; name_or_number
        else Etc.getpwnam(name_or_number).uid
        end
    end

    def name2gid name_or_number
        case name_or_number
        when Integer, Fixnum, Bignum; name_or_number
        else Etc.getgrnam(name_or_number).gid
        end
    end

    def owner
        File.stat(@resource[:path]).uid
    end

    def group
        File.stat(@resource[:path]).gid
    end

    def owner= newvalue
        stat = File.stat(@resource[:path])
        gid = stat.gid
        File.chown newvalue, gid, @resource[:path]
    end

    def group= newvalue
        stat = File.stat(@resource[:path])
        uid = stat.uid
        File.chown uid, newvalue, @resource[:path]
    end
end
