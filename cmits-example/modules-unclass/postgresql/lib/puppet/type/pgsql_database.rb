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
Puppet::Type.newtype(:pgsql_database) do
    @doc = "Ensure the existence of a database.

Example usage:

    pgsql_database { 'adatabase':
        os_user     => 'an_admin',
        db_user     => 'an_admin',
        database    => 'exists_already',
        owner       => 'another_user',
    }

This code would first become the OS user an_admin, then connect to the DBMS,
providing the username an_admin and the database exists_already as connection
parameters, and create the database adatabase, which will be owned by
another_user. (If the database didn't already exist.)

There is at this time no support for granting privileges on the database, nor
for creating objects in the database, nor for granting permission on such
objects.

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
        desc "Name of the database."
        newvalues SQL_IDENTIFIER_REGEX
    end
    newproperty(:owner) do
        desc "Owner of the database."
        newvalues SQL_IDENTIFIER_REGEX
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
        [
            catalog.resource(:pgsql_role, self[:owner]),
            catalog.resource(:pgsql_role, self[:db_user]),
        ]
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
    end
end
