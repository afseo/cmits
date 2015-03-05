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
# \section{FIPS 140-2 compliance, general}
#
# For compliance with Federal Information Processing Standard (FIPS) 140-2,
# there are two main ingredients: accreditation and configuration. The
# cryptographic modules used must be accredited, and they must be used in a
# compliant manner.
#
# (In some places in this document we say ``FIPS compliance.'' While we are
# likely to comply with other FIPS standards, 140-2 is the only one that
# anyone's asked about so far, so, for the time being, this is what ``FIPS
# compliance'' means.)

class fips {
    case $::osfamily {
        'RedHat': {
            case $::operatingsystemrelease {
                /^6\..*/: {
                    require fips::rhel6
                }
                /^5\..*/: {
                    require fips::rhel5
                }
                default: { unimplemented() }
            }
        }
        'Darwin': {
            require fips::darwin
        }
    }
}
