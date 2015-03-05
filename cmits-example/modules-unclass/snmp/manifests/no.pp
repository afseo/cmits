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
# \subsection{Disable SNMP}
#
# \notapplicable{unixsrg}{GEN005300}%
# We don't use SNMP on UNIX hosts (yet?). It's not merely inactive, it's not
# installed, so there are no default communities, users or passphrases.
#
# \notapplicable{unixsrg}{GEN005305}%
# If and when SNMP is ever deployed, do not use versions 1 or 2, but only
# version 3 or later.
#
# \notapplicable{unixsrg}{GEN005306,GEN005307}%
# Use FIPS 140-2 approved algorithms for SNMP.
#
# \notapplicable{unixsrg}{GEN005320,GEN005340,GEN005350,GEN005360,GEN005365,GEN005375}%
# Being as we don't run SNMP, none of its configuration files exist.

class snmp::no {
# \verb!tog-pegasus! depends on \verb!net-snmp!, so it must be removed also.
    package { [
            'net-snmp',
            'tog-pegasus',
        ]:
        ensure => absent,
    }
}
