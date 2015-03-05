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
# \section{Apache httpd}
#
# Configure the Apache web server in accordance with the Apache STIG
# \cite{apache-server-stig}~\cite{apache-site-stig}.
#
# Most of the requirements involve the Apache configuration. We don't have
# enough distinct web servers that imposing the configuration items by means of
# a Puppet policy would be expedient. So the STIG requirements are noted in
# each web server's configuration; all those configurations are
# version-tracked.
#
# Requirements best fulfilled by Puppet policy are written and documented here.

class apache($production=true) {
    package { "httpd":
        ensure => present,
    }
    service { 'httpd':
        enable => true,
        ensure => running,
        require => Package['httpd'],
    }
    include apache::fips
    case $production {
        'false', false: { include apache::stig::nonproduction }
        default: { include apache::stig::production }
    }
}
