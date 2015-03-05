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
# \subsection{RHEL 6 FIPS 140-2 compliance}
#
# The crypto modules in RHEL6 are FIPS Certified; see
# \url{http://www.redhat.com/solutions/industry/government/certifications.html}.
# Enabling FIPS mode in RHEL6 is documented in Section 8.2 of the
# Security Guide,
# \url{https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Security_Guide/sect-Security_Guide-Federal_Standards_And_Regulations-Federal_Information_Processing_Standard.html}.
#
# \documents{iacontrol}{DCNR-1}\documents{databasestig}{DG0025}%
# Database management system software included with RHEL uses the cryptographic
# modules included with RHEL, whose accreditation status is discussed
# in~\S\ref{class_fips}.
# % Yes, I know that's just above, but this paragraph will be plucked out and
# % used in the IA control compliance chapter.

class fips::rhel6 {

# Disable prelinking: it changes the library files, making checksums
# run against them come out with the wrong results. See the relevant
# section regarding when the un-prelinking will actually happen.
    include prelink::no

# Make sure we have fipscheck: FIPS-compliant OpenSSL uses it to check itself
# during startup.
    package {
        "fipscheck": ensure => present;
        "fipscheck-lib": ensure => present;
    }

# Prepare the initramfs for FIPS mode. (The \verb!dracut-fips! package
# may also be necessary for OpenSSL to successfully initialize in
# FIPS-compliant mode.)
    package { 'dracut-fips':
        ensure => present,
        notify => Exec['recreate initramfs file'],
    }
    exec { 'recreate initramfs file':
        refreshonly => true,
        command => '/sbin/dracut -f',
    }

# Disable old, unapproved cryptographic algorithms.
    include ssh::fips

# \implements{unixsrg}{GEN005490,GEN005495} Ensure that OpenSSH will operate in
# a FIPS-compliant fashion, by configuring the OpenSSL cryptographic library to
# run in FIPS 140-2 compliant mode.
#
# Turn on the \verb!fips=1! kernel parameter. This changes how OpenSSL starts
# up and may effectively disable OpenSSH if you are not properly prepared.
    include grub::fips

# ``Enforced FIPS mode'' for gcrypt: Documentation for this mode
# is in \url{http://www.gnupg.org/documentation/manuals/gcrypt.pdf}, Appendix
# B, ``Description of the FIPS mode.'' The reason why not to use it, even
# though it sounds like a good thing to enable, is written in
# \url{https://bugzilla.redhat.com/show_bug.cgi?id=869827}. In short, it breaks
# \emph{all} SSL/TLS connections. (TLS $\geq$ 1.2 could work, but it's only
# been standardized for four months at this writing. Not practical.)
    file { '/etc/gcrypt/fips_enabled':
        ensure => absent,
    }
}

# The last step in the guide is to reboot the system. From Puppet, we
# aren't in a position to force this.
#
# In addition to these measures, FIPS mode must also be enabled for
# each Network Security Services (NSS) database in use; this isn't a
# useful thing to do for \verb!/etc/pki/nss!, the systemwide NSS
# database, because it would ask for a password before doing anything
# interesting, and the password would have to be systemwide. But
# see~\S\ref{module_apache} module for how we make sure NSS databases
# used by Apache httpd's \verb!mod_nss! module are placed into FIPS
# mode.
