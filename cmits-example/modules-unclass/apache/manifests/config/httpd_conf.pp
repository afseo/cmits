# % --- BEGIN DISCLAIMER ---
# % Those who use this do so at their own risk;
# % AFSEO does not provide maintenance nor support.
# % --- END DISCLAIMER ---
# % --- BEGIN AFSEO_DATA_RIGHTS ---
# % This is a work of the U.S. Government and is placed
# % into the public domain in accordance with 17 USC Sec.
# % 105. Those who redistribute or derive from this work
# % are requested to include a reference to the original,
# % at <https://github.com/afseo/cmits>, for example by
# % including this notice in its entirety in derived works.
# % --- END AFSEO_DATA_RIGHTS ---
# \subsubsection{httpd.conf}
#
# Assumption: we are starting with a stock RHEL6 httpd configuration.
#
# Parameter \verb!max_request_body! is given in bytes. If a website
# supports file uploads via POST requests, the \verb!max_request_size!
# must be set a few kilobytes larger than the largest file that should
# be uploadable.

class apache::config::httpd_conf($max_request_body=4194304) {
    if $::osfamily != 'RedHat' or $operatingsystemrelease !~ /^6\./ {
        unimplemented()
    }

    include apache
    
    $abbr_ehchc  = '/etc/httpd/conf/httpd.conf'
    $abbr_fehchc = "/files/${abbr_ehchc}"

    Augeas {
        incl => $abbr_ehchc,
        lens => 'Httpd.lns',
        notify => Service['httpd'],
    }

# Ensure a directive is in place and set to a given value, in the
# toplevel of httpd.conf.
    define toplevel_directive($arguments) {
        $abbr_ehchc = $apache::config::httpd_conf::abbr_ehchc
        directive { "${abbr_ehchc}:${name}":
            context_in_file => "",
            arguments => $arguments,
        }
    }

# Ensure a directive is in place and set to a given value, in
# \verb!<Directory />! in httpd.conf.
    define root_dir_directive($arguments) {
        $abbr_ehchc = $apache::config::httpd_conf::abbr_ehchc
        directive { "${abbr_ehchc}:root:${name}":
            context_in_file => "Directory[arg='/']",
            arguments => $arguments,
        }
    }

# Ensure a directive is in place and set to a given value, in
# \verb!<Directory /var/www>! in httpd.conf.
    define var_www_dir_directive($arguments) {
        $abbr_ehchc = $apache::config::httpd_conf::abbr_ehchc
        directive {
            "${abbr_ehchc}:varwww:${name}":
                context_in_file => "Directory[arg='/var/www']",
                arguments => $arguments;
        }
    }

    context { "${abbr_ehchc}:root":
        context_in_file => '',
        type => 'Directory',
        arguments => ['/'],
    }
    context { "${abbr_ehchc}:varwww":
        context_in_file => '',
        type => 'Directory',
        arguments => ['/var/www'],
    }
    # augeas { 'httpd.conf root directory add':
    #     context => $abbr_fehchc,
    #     changes => [
    #         'clear Directory[999]',
    #         'set Directory[999]/arg "/"',
    #         ],
    #     onlyif => 'match Directory[arg="/"] size == 0',
    # }
    # augeas { 'httpd.conf varwww directory add':
    #     context => $abbr_fehchc,
    #     changes => [
    #         'clear Directory[998]',
    #         'set Directory[998]/arg "/var/www"',
    #         ],
    #     onlyif => 'match Directory[arg="/var/www"] size == 0',
    # }

    toplevel_directive {
# Avoid warnings about not being able to determine ServerName. This
# will be overridden in the virtual site configuration anyway.
        'ServerName': arguments => [$::fqdn];
        
# Don't tell visitors what OS we are running.
        'ServerTokens': arguments => ['ProductOnly'];

# \implements{apachestig}{WA000-WWA020 A22}%
        'Timeout': arguments => [120];

# \implements{apachestig}{WA000-WWA022 A22}%
        'KeepAlive': arguments => ['on'];

# \implements{apachestig}{WG110 A22}%
# Set MaxKeepAliveRequests to 100 ``or greater.''
        'MaxKeepAliveRequests': arguments => [100];

# \implements{apachestig}{WA000-WWA024 A22}%
        'KeepAliveTimeout': arguments => [15];

# \implements{apachestig}{WA000-WWA060 A22}%
# Limit request body size. The actual limit is not specified by the STIG.
        'LimitRequestBody': arguments => [$max_request_body];

# \implements{apachestig}{WA000-WWA062 A22}%
# Limit number of HTTP request header fields.
        'LimitRequestFields': arguments => [50];

# \implements{apachestig}{WA000-WWA064 A22}%
# Limit size of each HTTP request header field, to ``8190 or other
# approved value.''
        'LimitRequestFieldSize': arguments => [8190];

# \implements{apachestig}{WA000-WWA066 A22}%
# Limit HTTP request line length, to ``8190 or other approved value.''
        'LimitRequestLine': arguments => [8190];
    }

# Remove toplevel Listen directive: leave it to per-website
# configuration to Listen.
    augeas { "httpd.conf remove Listen":
        context => $abbr_fehchc,
        changes => 'rm directive[.="Listen"]',
    }

# \implements{apachestig}{WA00500 A22}%
# Minimize active software modules.
    define remove_module_load() {
        $abbr_fehchc = $apache::config::httpd_conf::abbr_fehchc
        $abbr_ehchc = $apache::config::httpd_conf::abbr_ehchc
        augeas { "httpd.conf remove module ${name}":
            context => $abbr_fehchc,
            changes => "rm \
                directive[.='LoadModule' and arg[1]='${name}']",
        }
    }

    remove_module_load { [
        'auth_digest_module',
        'authn_anon_module',
        'authn_dbm_module',
        'authz_owner_module',
        'authz_dbm_module',
        'include_module',
        'ext_filter_module',
        'expires_module',
        'headers_module',
        'usertrack_module',

# \implements{apachestig}{WA00510 A22}%
# Disable status module.
        'status_module',
        'info_module',
# Turn off all we can of DAV.
# See \url{http://svn.haxx.se/users/archive-2004-12/0709.shtml}.
        'dav_fs_module',
        'speling_module',
# \implements{apachestig}{WA00525 A22}%
# Disable user-specific directories.
        'userdir_module',
# These may break applications that use Apache as a proxy for a web
# application container that runs its own web server.
# \implements{apachestig}{WA00520 A22}%
# We would need reverse proxying for Plone---but we don't tend to use
# Plone anymore.
        'proxy_module',
        'proxy_balancer_module',
        'proxy_ftp_module',
        'proxy_http_module',
        'proxy_ajp_module',
        'proxy_connect_module',
        'cache_module',
        'suexec_module',
        'disk_cache_module',
        'version_module',
        ]: }

# \unimplemented{apachestig}{WA00505 A22}{WebDAV is supposed to be
# disabled, but Subversion requires it.}
# \unimplemented{apachestig}{WG170 A22}{Autoindexes are supposed to be
# disabled, but SBU requires them.}

# \implements{apachestig}{WA000-WWA052 A22}%
# Disable the FollowSymLinks option; Options None does this.
    toplevel_directive { 'Options': arguments => ['None'] }

# \implements{apachestig}{WA00545 A22}%
# Disable all options at the OS root.
#
    root_dir_directive { 'Options': arguments => ['None'] }

# \implements{apachestig}{WA00547 A22}%
# Disable access configuration override at the OS root.
    root_dir_directive { 'AllowOverride': arguments => ['None'] }

# \implements{apachestig}{WA00540 A22}%
# Deny access to the OS root. (Access is allowed by exception in other
# parts of the web server configuration.)
    root_dir_directive { 'Order': arguments => ['deny,allow'] } ->
    root_dir_directive { 'Deny': arguments => ['from', 'all'] }

# \implements{apachestig}{WA00550 A22}%
# Disable TRACE method.
    toplevel_directive { 'TraceEnable': arguments => ['off'] }

# \implements{apachestig}{WA000-WWA054 A22}%
# Avoid executing things using server-side includes (SSIs). We don't
# use SSIs so they are just turned off altogether (see include\_module
# above).
#
# \implements{apachestig}{WA000-WWA056 A22}%
# Disable MultiViews.
#
# \implements{apachestig}{WA000-WWA058 A22}%
# Disable auto-indexing by default.
    var_www_dir_directive { 'Options': arguments => ['None'] }

# \implements{apachestig}{WA00565 A22}%
# Limit HTTP request methods.
#
# Other methods than these might be allowed in certain places inside
# the website.
    context {
        "${abbr_ehchc}:varwww:limitexcept":
            context_in_file => "Directory[arg='/var/www']",
            type => 'LimitExcept',
            arguments => ['GET', 'POST', 'OPTIONS'];
    }
    directive { "${abbr_ehchc}:varwww:limitexcept:Deny":
        arguments => ['from', 'all'],
        context_in_file => "Directory[arg='/var/www']/LimitExcept",
    }


    toplevel_directive { 'ErrorLog': arguments => ['syslog'] }

# \implements{apachestig}{WA00612 A22}%
# Use the ``correct format'' for logs.
    augeas { 'change log format at toplevel in httpd.conf':
        context => "${abbr_fehchc}/directive[\
            .='LogFormat' and arg[2]='combined']",
        changes => "set arg[1] \
'\"%a %A %h %H %l %m %s %t %u %U \\\"%{Referer}i\\\" \"'",
    }

    toplevel_directive { 'ServerSignature': arguments => ['Email'] }

# The icons directory doesn't need any options.
    augeas { "httpd.conf icons remove Options":
        context => "${abbr_fehchc}/Directory[arg='/var/www/icons']",
        changes => 'rm directive[.="Options"]',
    }
}
