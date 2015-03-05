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
# \subsection{Daily cron job}
#
# Make sure something happens every day---portably.
#
# On Red Hattish Linux hosts, \verb!/etc/cron.daily! exists and is a
# directory, and executable files inside it are run once a day. On Mac
# hosts, this directory does not exist.

define cron::daily($source) {
    case $::osfamily {
        'RedHat': {
            file { "/etc/cron.daily/${name}":
                owner => root, group => 0, mode => 0700,
                source => $source,
            }
        }
        'Darwin': {
            warning 'cron::daily unimplemented on Macs'
        }
    }
}
