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
# \subsection{RHEL 5 FIPS 140-2 guidance}
#
# This is just like RHEL 6 but simpler: the knowledge base article
# \url{https://access.redhat.com/kb/docs/DOC-39230} applies directly.
#
# See
# \url{http://www.redhat.com/solutions/industry/government/certifications.html}
# for FIPS approval status of crypto modules in RHEL.

class fips::rhel5 {
# Make sure we have fipscheck: FIPS-compliant OpenSSL uses it to check itself
# during startup.
    package {
        "fipscheck": ensure => present;
        "fipscheck-lib": ensure => present;
    }

    include prelink::no
    include grub::fips
    include ssh::fips

}
