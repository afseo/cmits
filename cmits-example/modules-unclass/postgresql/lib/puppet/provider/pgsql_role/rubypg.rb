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
require 'pg' if Puppet.features.pg?
require 'yaml'
require 'etc'

Puppet::Type.type(:pgsql_role).provide :rubypg do
    confine :true => Puppet.features.pg?

    desc "Manage PostgreSQL roles using Ruby's pg library."

    # Do a query against the database.
    #
    # The easiest way to do local authentication with PostgreSQL is the ident
    # method, where the PostgreSQL server identifies which local user opened
    # the UNIX socket and consults a map of OS users to permissible database
    # users.
    #
    # Since this is the method used, before we connect to the database to do
    # something, we need to become the correct user, because root may not be
    # allowed to connect as the database user given. Also we do not give a host
    # or port, because these are not used when UNIX sockets are in use.
    #
    # But once we drop root we can't get it back, so we need to do it in a
    # subprocess. Results are passed back through a pipe in YAML format.
    #
    # It is expected that any results from a query will be smaller than, say,
    # 20K. No scalability guarantees are made. Obviously none of the niceties
    # of an ORM are provided.
    def _exec_sql sql, params
        os_user = Etc.getpwnam(resource[:os_user])
        os_uid = os_user.uid
        # use primary group of the os_user
        os_gid = os_user.gid
        # these two variables make everything inside the fork independent of
        # puppet, for what that's worth
        db_user = resource[:db_user]
        database_name = resource[:database]
        # the following two defaults are how psql usually works
        db_user = resource[:os_user] if db_user == ''
        database_name = db_user if database_name == ''

        debug "Executing #{sql.inspect} with params #{params.inspect}"
        r, w = IO.pipe
        fork do
            r.close
            Process::Sys.setgid os_gid
            Process::Sys.setuid os_uid
            # should we close everything? but we can't close the pipe...
            catch (:done) do
                begin
                    c = PGconn.new(:dbname => database_name, :user => db_user)
                    begin
                        result = c.exec sql, params
                        c.close
                        w.print({'ok' => result.to_a}.to_yaml)
                        throw :done
                    rescue Exception => e
                        w.print({'execution_error' => e.message}.to_yaml)
                        throw :done
                    end
                rescue Exception => e
                    w.print({'connection_error' => e.message}.to_yaml)
                    throw :done
                end
            end
            w.close
        end
        w.close
        result = YAML::load(r.read)
        fail "could not connect as #{db_user} to local database #{database_name} while being the OS user #{resource[:os_user]}: #{result['connection_error']}" if result.include? 'connection_error'
        fail "could not execute #{sql} with params #{params} as #{db_user} in local database #{database_name}: #{result['execution_error']}" if result.include? 'execution_error'
        return result['ok']
    end

    def _role_info
        return @cached_role_info unless @cached_role_info.nil?
        role_info = _exec_sql(
            # ::name: coerce parameter to name type
            'SELECT * FROM pg_roles WHERE rolname = $1::name;',
            [{:value => resource[:name], :format => 0}])
        # role_info is an array of rows. if nothing was selected, it will be
        # [], and [][0] == nil (in Python this would cause an IndexError)
        @cached_role_info = role_info[0]
        return @cached_role_info
    end

    def invalidate_cached_role_info
        @cached_role_info = nil
    end

    def exists?
        not _role_info.nil?
    end

    # Here's where it comes in handy that the attributes named by the type
    # correspond exactly to optional parameters to the CREATE ROLE command.
    #
    # Password setting not supported. We don't need it when the database is
    # local, and when the database is not local and users need to log in, we'll
    # use Kerberos.
    def create
        possible_options = [:createdb, :createrole, :inherit, :superuser, :login]
        options_to_add = possible_options.map {|o|
            # Set all role attributes on or off, disregarding PostgreSQL
            # defaults, so that the role is exactly as prescribed in the
            # manifest.
            (if resource[o] == :true then '' else 'NO' end) + o.to_s.upcase
        }.join(' ')
        # SQL injection defense: the resource name is validated for content and
        # length before we inject it; the name is provided by admins, not users.
        sql = "CREATE ROLE #{resource[:name]} #{options_to_add}"
        _exec_sql sql, []
        # now grant specified roles to the new role
        self.grant_roles= resource[:grant_roles]
    end

    def destroy
        # SQL injection defense: see create method above
        _exec_sql "DROP ROLE #{resource[:name]}", []
        invalidate_cached_role_info
    end

    # maps parameter names used in Puppet DSL to column names in pg_roles table 
    PUPPET_PG_ROLES_COLUMN = {
        'createdb' => 'rolcreatedb',
        'createrole' => 'rolcreaterole',
        'inherit' => 'rolinherit',
        'superuser' => 'rolsuper',
        'login' => 'rolcanlogin',
    }
    # maps strings returned in PGresults as values of bool columns to symbols
    PG_BOOL_SYMBOL = {
        't' => :true,
        'f' => :false,
        # just in case
        nil => :false,
    }

    PUPPET_PG_ROLES_COLUMN.each do |property, column|
        define_method(property.to_sym) do
            # _role_info is a hash containing each column; values of this boolean 
            PG_BOOL_SYMBOL[_role_info[column]]
        end
        define_method((property + '=').to_sym) do |newvalue|
            # As noted above the create method, the Puppet property names
            # correspond to options to the SQL CREATE ROLE command. ALTER ROLE
            # supports the same options.
            prefix = if [:true, true].include? newvalue then "" else "NO" end
            alter_option = prefix + property.upcase
            _exec_sql "ALTER ROLE #{resource[:name]} #{alter_option}", []
            invalidate_cached_role_info
        end
    end
    def grant_roles
        user_oid = _role_info['oid']
        # might as well get it all done in one query.
        rows = _exec_sql \
            'SELECT rolname FROM pg_roles WHERE oid IN ' \
            ' (SELECT roleid FROM pg_auth_members WHERE member = ' \
            '   (SELECT oid FROM pg_roles WHERE rolname = $1::name))' \
            'ORDER BY rolname',
            [{:value => resource[:name], :format => 0}]
        result = rows.map {|r| r['rolname']}
        # because of http://projects.puppetlabs.com/issues/10237; see the type too
        result = [:none] if result == []
        debug "present grant_roles is value is #{result.inspect}"
        return result
    end
    def grant_roles= newvalue
        debug "grant_roles= called with #{newvalue.inspect}"
        roles_now = grant_roles
        if newvalue.include? :none
            to_revoke = roles_now - [:none]
            to_grant = []
        else
            to_revoke = roles_now - newvalue - [:none]
            to_grant = newvalue - roles_now
        end
        # SQL injection defense: new values to use are checked by resource
        # type, and provided by admins writing the manifest, not users
        _exec_sql("GRANT #{to_grant.join(',')} TO #{resource[:name]}", []) \
            if to_grant.any?
        _exec_sql("REVOKE #{to_revoke.join(',')} FROM #{resource[:name]}", [])\
            if to_revoke.any?
        invalidate_cached_role_info
    end
end

