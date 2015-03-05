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
# \subsection{Development box}
# A host where Puppet manifests are to be developed.

class puppet::devel {
    include puppet::client
    include common_packages::graphviz
    include common_packages::latex
    package { [
        "puppet-server",
    ]:
        ensure => installed,
    }

# Stored configs depend on Rails, which RHEL does not provide as RPMs,
# so we must install the gems. Passenger involves some manual stuff
# that may not be automatable just yet.

    package { [
        'rspec',
        'rspec-puppet',
    ]:
        provider => gem,
        ensure => installed,
        source => "",
    }
}
