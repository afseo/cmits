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
# \subsection{Sendmail}
#
# When sendmail configuration changes, we must regenerate the real
# configuration, then reload sendmail.

class smtp::sendmail {
    service { "sendmail":
        restart => "/sbin/service sendmail reload",
    }

    package { 'sendmail-cf':
        ensure => installed,
    }
    require common_packages::make

    exec { 'update_sendmail_config':
        command => 'make -C /etc/mail',
        require => [
            Package['sendmail-cf'],
            Package['make'],
            ],
        refreshonly => true,
        notify => Service['sendmail'],
    }
}
