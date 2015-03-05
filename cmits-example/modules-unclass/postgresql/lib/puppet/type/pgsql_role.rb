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
Puppet::Type.newtype(:pgsql_role) do
    @doc = "Apply policy to PostgreSQL roles.

Example usage:

    pgsql_role { 'dba':
        login      => false,
        superuser  => false,
        inherit    => false,
        createrole => true,
        createdb   => true,
        os_user     => 'puppet_dba',
        db_user     => 'puppet_dba',
        database    => 'puppet_dba',
    }

    pgsql_role { 'joe':
        login       => true,
        inherit     => true,
        grant_roles => ['dba'],
        os_user     => 'puppet_dba',
        db_user     => 'puppet_dba',
        database    => 'puppet_dba',
    }

This resource type only lets you express \"role attributes,\" not permissions
against database objects: creation of database objects and roles with
permissions to use such objects presently happens outside Puppet in our
organization.

See Chapter 20 of the PostgreSQL documentation about roles, their commonalities
with users, and the exact meanings of these attributes.

"
    ensurable do
        defaultvalues
        defaultto :present
    end

    # See http://www.postgresql.org/docs/8.4/static/datatype-character.html for
    # length limitations; as of PostgreSQL 8.4, there are 63 usable bytes in a
    # name. SQL syntax constrains the value of the first character; see
    # http://www.postgresql.org/docs/8.4/static/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS
    SQL_IDENTIFIER_REGEX = /^[a-z_][-a-z0-9_]{0,62}$/

    newparam(:name) do
        desc "Name of the role."
        newvalues SQL_IDENTIFIER_REGEX
        validate do |value|
            fail "You cannot create a role named 'none' with this resource type" if value.to_s == 'none'
        end
    end
    newproperty(:login) do
        desc "If true, the role can log into the database (is a user)."
        newvalues :true, :false
        defaultto :false
    end
    newproperty(:inherit) do
        desc "If true, the role automatically inherits privileges of roles granted to it. Should usually be true for 'users,' false for 'roles.'"
        newvalues :true, :false
        defaultto :false
    end
    newproperty(:superuser) do
        desc "If true, the role or user is not subject to permissions."
        newvalues :true, :false
        defaultto :false
    end
    newproperty(:createrole) do
        desc "Grants permission to create more roles to the role or user."
        newvalues :true, :false
        defaultto :false
    end
    newproperty(:createdb) do
        desc "Grants permission to create new databases."
        newvalues :true, :false
        defaultto :false
    end
    newproperty(:grant_roles, :array_matching => :all) do
        desc "Role or list of roles that should be granted to this role or user.
            
        N.B. If you want the user to be granted no roles, you cannot provide []
        as a value: see http://projects.puppetlabs.com/issues/10237. So instead
        write grant_roles => none. As a consequence you cannot create a role
        named none with this resource type.
        "
        newvalues :none, SQL_IDENTIFIER_REGEX
        def is_to_s(current_value=@is)
            if current_value == [:none]
                "(none)"
            else
                current_value.join(',')
            end
        end
        def should_to_s(should_value=@should)
            if should_value == [:none]
                "(none)"
            else
                should_value.join(',')
            end
        end
    end
    newparam(:os_user) do
        desc "OS user (instead of root) to use when connecting to the database."
        # http://projects.puppetlabs.com/issues/4049
        # http://groups.google.com/group/puppet-dev/browse_thread/thread/ff4447dcd921a9f6
        # short version: isrequired doesn't really do anything! see the
        # per-type validate method below for how this is actually enforced
        isrequired
        validate do |value|
	    # let's be generous and allow 31-character OS usernames, even
	    # though they should be 8 chars or less, because 8 chars is only
	    # traditional and I think Linux allows more
            raise ArgumentError, "Value for os_user is not a valid username" unless value =~ /^[a-z_][-a-z0-9_]{0,30}$/
        end
    end
    newparam(:db_user) do
        desc "Username to tell the database when connecting."
        # if we don't provide one, sometimes that just works, based on which OS
        # user we are at the time
        defaultto ''
        newvalues /^$/, SQL_IDENTIFIER_REGEX
    end
    newparam(:database) do
        desc "Database name to tell the DBMS when connecting."
        newvalues SQL_IDENTIFIER_REGEX
    end

    autorequire(:pgsql_role) do
        roles_needed = self[:grant_roles].reject {|x| x == :none}.map do |rol|
            catalog.resource(:pgsql_role, rol.to_s)
        end
        roles_needed + [catalog.resource(:pgsql_role, self[:db_user])]
    end

    autorequire(:pgsql_database) do
        catalog.resource(:pgsql_database, self[:database])
    end

    # We require the PostgreSQL DBMS server to be running
    autorequire(:service) do
        catalog.resource(:service, 'postgresql')
    end

    validate do
        symbols_given = @parameters.map {|x| x[0]}
        if !symbols_given.include? :os_user
            fail "You must supply a value for os_user"
        end
        self[:grant_roles] = [:none] if self[:grant_roles].nil?
        self[:grant_roles] = self[:grant_roles].sort
    end
end
