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
class cups::redhat {
# Since \verb!cups::no! uninstalls CUPS, and this class already assumes CUPS is
# installed, we may as well make sure of it, so that if some node switches from
# including \verb!cups::no! to including \verb!cups::stig!, things will work
# better. But CUPS is not necessarily all that must be installed for printing
# to work properly in a given situation.
    package { 'cups':
        ensure => present,
    }
    service { 'cups':
        enable => true,
        ensure => running,
        require => Package['cups'],
    }
}
