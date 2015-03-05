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
# \section{Mac packages}
#
# The \verb!apple! and \verb!pkgdmg! providers for the \verb!package!
# resource type require that a \verb!source! parameter be given. Mac
# packages will be stored on some NFS or HTTP location, but that
# location is specific to a given network, and \verb!modules-unclass!
# is supposed to be generic.
#
# This define exists to gather all of the references to such a location
# into one place.

define mac_package(
    $ensure='installed',
    $sourcedir='',
    ) {

# We haven't got Hiera installed on our Puppet 2 master server.
    if $sourcedir == '' {
        if $::puppet_version !~ /^3\./ {
            $use_source = '/'
        } else {
            $use_source = hiera('mac_package::sourcedir', '/')
        }
    } else {
        $use_source = $sourcedir
    }

# Attempt to autorequire the network mount that the sourcedir appears
# to be on.
    if $use_source =~ /^(\/net\/[^\/]+)/ {
        if defined(Mac_automount[$1]) {
            $requires = [Mac_automount[$1]]
        } else {
            $requires = []
        }
    } else {
        $requires = []
    }

    package { $name:
        ensure => $ensure,
        source => "${use_source}/${name}",
        require => $requires,
    }
}
