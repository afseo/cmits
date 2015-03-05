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
# \subsubsection{Log rules for Macs}

class log::stig::darwin {
# \implements{mlionstig}{OSX8-00-00815}%
# Make sure root:wheel owns the system log files listed in the syslog
# configuration.
    exec { 'chown mac logs':
        command => 'grep ^/ /etc/newsyslog.conf | \
                    awk "{print \$1}" | \
                    xargs chown root:wheel',
        unless => 'grep ^/ /etc/newsyslog.conf | \
                   awk "{print \$1}" | \
                   xargs stat -f "%Su:%Sg" 2>/dev/null | \
                   grep -v "^root:wheel\$" | \
                   awk "BEGIN{x=0;}{x=1;}END{exit x;}"',
    }
# \implements{mlionstig}{OSX8-00-00820}%
# Ensure restrictive permissions for system log files.
    exec { 'chmod mac logs':
        command => 'grep ^/ /etc/newsyslog.conf | \
                    awk "{print $1}" | \
                    xargs chmod g-w,o-rwx',
        unless => 'grep ^/ /etc/newsyslog.conf | \
                   awk "{print $1}" | \
                   xargs stat -f "%Sp" 2>/dev/null | \
                   grep -v "^.rw..-----\$" | \
                   awk "BEGIN{x=0;}{x=1;}END{exit x;}"',
    }

# (On a stock Mavericks system it looks like none of these files
# actually exist.)
#
# \implements{mlionstig}{OSX8-00-01025}%
# Enable local logging on Macs.
    service { 'com.apple.newsyslog':
        enable => true,
        ensure => running,
    }
# \bydefault{Mavericks}{mlionstig}{OSX8-00-01030}%
# The default setting for how many logs to keep is 5. This is adequate
# for this organization at this time.
}

