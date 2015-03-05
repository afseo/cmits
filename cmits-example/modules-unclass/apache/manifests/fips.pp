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
# \subsection{FIPS-required configuration}
#
# Configure Apache httpd in a manner compliant with FIPS 140-2. We do this
# using \verb!mod_nss! instead of \verb!mod_ssl!; see \ref{httpd-mod-nss} for
# more details.

class apache::fips {
    include apache
    package {
        "mod_nss":
            ensure => present,
            notify => Service['httpd'];
        "mod_ssl":
            ensure => absent,
            notify => Service['httpd'];
    }

# The NSS security policy \cite{nss-security-policy} may require that the NSS
# cryptographic module be auditable. To make it so, we must tell it to log what
# it does, via an environment variable.
#
# I hope it does not require this because the thing is way too verbose - on the
# order of fifteen or twenty lines of log per HTTPS request. Turning it off for
# now. To turn back on, change the line below from ``set \$nea 0'' to ``set
# \$nea 1''.

    $nea = "NSS_ENABLE_AUDIT"
    augeas { "httpd_nss_audit":
        context => "/files/etc/sysconfig/httpd",
        changes => [
            "rm #comment[.=~regexp('$nea:.*')]",
            "set #comment[last()+1] \
             '$nea: maybe necessary for FIPS compliance'",
            "rm $nea",
            "set $nea 0",
            # make the export exist in the tree but have no value
            "clear $nea/export",
        ],
# Don't do this before httpd is installed, otherwise the stock
# \verb!/etc/sysconfig/httpd! will be installed as a \verb!.rpmnew!.
        require => Package['httpd'],
        notify => Service['httpd'],
    }
}

# \subsection{On the use of mod\_nss}
# \label{httpd-mod-nss}
#
# The usual way of configuring SSL/TLS on an Apache server is to use
# \verb!mod_ssl!, which uses OpenSSL libraries to do the cryptographic work.
#
# As of 2 May 2011, when using \verb!mod_ssl! on a FIPS-enabled host,
# \verb!httpd! 2.2.15 will not start, citing failure to generate a 512-bit
# temporary key. An SSL+FIPS patch exists
# (\url{http://people.apache.org/~wrowe/ssl-fips-2.2.patch}). Judging by a
# reading of this patch, the failure to generate a temporary key is not because
# of a lack of available entropy for the pseudo-random number generator, as the
# documentation says, but perhaps because this is the first cryptographic
# thing that \verb!httpd! is trying to do, and it hasn't called OpenSSL's
# \verb!FIPS_mode_set! function first, so OpenSSL fails to do anything. The
# patch would fix this, but it is not in the vendor-supported \verb!httpd!
# package.
#
# Red Hat does provide \verb!mod_nss!, which uses the NSS libraries to do
# cryptographic work instead of OpenSSL. FIPS-accredited versions of NSS
# exist. I found a Red Hat bug from 2008 where someone was talking about having
# used the \verb!NSSFIPS! directive in the Apache configuration. So it would
# appear that this a more vendor-supported path to FIPS-compliant TLS under
# Apache \verb!httpd!.
#
# (The quickest and most familiar route would be to turn off OS-wide FIPS mode
# (see \S\ref{class_fips}); but the UNIX SRG requires that to be on.)
#
#
# \subsection{Private key security under OpenSSL and NSS}
#
# Usually, under \verb!mod_ssl!, private keys are in files owned by root, and
# accessible only by root; the \verb!httpd! process starts as root, reads the
# files during startup, then drops root and becomes the \verb!apache! user for
# the rest of its life. If someone were to exploit a vulnerability in
# \verb!httpd!, they could run arbitrary code as the \verb!apache! user; but
# \verb!apache! cannot read the private key files. This makes me feel good.
#
# Under \verb!mod_nss!, private keys are in the NSS database, in an encrypted
# file. The database's use is internal to NSS, so it must be assumed that NSS
# could access it at any time; there are no privileges that can be dropped. So
# the NSS database files must be owned not by root, but by \verb!apache!. That
# means our hypothetical attacker can read them. This makes me feel nervous.
#
# But the private keys are encrypted and can only be decrypted with a password.
# Perhaps the attacker could read the password out of \verb!httpd!'s memory?
# But the documentation about NSS written in support of its FIPS
# certification\footnote{\url{https://wiki.mozilla.org/VE_07KeyMgmt}} says,
# ``Passwords are automatically zeroized by the NSS cryptographic module
# immediately after use.'' So that can't happen.
#
# In either case, the unencrypted private key is in \verb!httpd!'s memory
# while it's running, anyway.
#
# As the same document and the NSS security policy \cite{nss-security-policy}
# both say, ``Since password-based encryption such as PKCS \#5 is not FIPS
# Approved, the private and secret keys in the private key database are
# considered in plaintext form by FIPS 140-2 (see FIPS 140-2 Section 4.7 and
# FIPS 140-2 IG 7.1);'' however, password-based encryption is not considered in
# plaintext form by attackers until after the application of many CPU-hours of
# work, so it is not without benefit.
