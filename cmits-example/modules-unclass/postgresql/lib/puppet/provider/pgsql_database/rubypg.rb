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

Puppet::Type.type(:pgsql_database).provide :rubypg do
    confine :true => Puppet.features.pg?

    desc "Manage PostgreSQL databases using Ruby's pg library.

    (This is just databases and who owns them that we're managing here, not
    also the objects inside them, nor the permissions of those objects.)

    "

    # Do a query against the database. Ripped straight out of pgsql_role.
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

    def _database_info
        info = _exec_sql(
            'SELECT * FROM pg_database WHERE datname = $1::name;',
            [{:value => resource[:name], :format => 0}])
        # if info is an empty array this will be nil (unlike Python which would
        # raise an IndexError)
        return info[0]
    end

    def exists?
        not _database_info.nil?
    end

    def create
        # Yadda yadda, value provided by admins, validated in resource type
        # code before we see it here.
        _exec_sql "CREATE DATABASE #{resource[:name]} OWNER #{resource[:owner]}", []
    end

    def destroy
        # SQL injection defense: see create method above
        _exec_sql "DROP DATABASE #{resource[:name]}", []
    end

    def owner
        result = _exec_sql(
            'SELECT rolname FROM pg_roles, pg_database ' \
            'WHERE datdba = pg_roles.oid AND datname = $1::name;',
            [{:value => resource[:name], :format => 0}])
        return result[0]['rolname']
    end

    def owner= newvalue
        _exec_sql(
            "ALTER DATABASE #{resource[:name]} OWNER TO #{newvalue}", [])
    end
end

