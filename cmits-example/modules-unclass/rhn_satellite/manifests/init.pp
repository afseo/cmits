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
# \section{Red Hat Network Satellite}
#
# Red Hat Network (RHN) Satellite servers are manually set up, entirely
# according to Red Hat's fine documentation. (Seriously, it's well-written and
# complete.) Any exceptions will be noted and/or controlled here.

class rhn_satellite {

# The RHN Satellite services are not managed by the service subsystem; there is
# a separate rhn-satellite executable which takes parameters stop, start,
# restart, status, etc.
    exec { 'rhn_satellite_restart':
        refreshonly => true,
        command => '/usr/sbin/rhn-satellite restart',
    }
}
