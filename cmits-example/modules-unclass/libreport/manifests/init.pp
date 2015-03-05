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
# \section{libreport}
#
# When a crash happens, it appears this library is used to send news
# of it to someone, somewhere, somehow. For example, an email may be
# sent.

class libreport {
    case $::osfamily {
        'RedHat': {
            augeas { 'libreport_set_from_address':
                context => '/files/etc/libreport/plugins/mailx.conf',
                changes => "set EmailFrom 'root@${::fqdn}'",
            }
        }
        default: {}
    }
}
