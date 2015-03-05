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
# \subsection{Disabling prelinking}

class prelink::no {
    package { 'prelink':
        ensure => installed,
    }
# The \verb!/etc/sysconfig/prelink! file says that \verb!prelink -ua! will be
# run the next night if \verb!PRELINKING! is set to no. This happens by means
# of \verb!/etc/cron.daily/prelink!.
#
# But in between now and then, if a reboot happens, we'll be running
# in FIPS mode without having un-prelinked the libraries. This will
# cause familiar and important parts of the system such as yum and ssh
# to break. So if and only if we've changed the above, we should go
# ahead and run \verb!prelink -ua! now.
    augeas { "disable_prelinking":
        context => "/files/etc/sysconfig/prelink",
        changes => "set PRELINKING no",
        notify => Exec['unprelink now'],
    }
    exec { 'unprelink now':
        command => '/usr/sbin/prelink -ua',
        refreshonly => true,
        require => Package['prelink'],
    }
}
