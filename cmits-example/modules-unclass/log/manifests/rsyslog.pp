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
# \subsection{Logging via rsyslog}
#
# % Escape pound signs in URLs with a backslash or you will get the LaTeX
# % error "Illegal parameter number in definition of \Hy@tempa."
# % -- http://suchideas.com/articles/computing/latex/errors/
# % Furthermore, you can't put a verbatim inside a footnote. WTF
#
# RHEL6 uses \verb!rsyslog! as its default logging d{\ae}mon. \verb!rsyslog!
# supports remote logging over TCP, and TLS encryption using GnuTLS. But it
# appears not to support CRLs, nor OCSP.\footnote{
#     According to
#      \href{http://git.adiscon.com/?p=rsyslog.git;a=blob;f=runtime/nsd\_gtls.c;h=d0fd0e0fb710549cdc1ade69bc55c7d2e2f8db72;hb=HEAD\#l628}{the
#     rsyslog Git repository as of 2011 Jun 09}, \texttt{runtime/nsd\_gtls.c},
#     line 628, has a comment indicating that as of May 2008 the author, Rainer
#     Gerhards, ``doubt[s] we'll ever [use CRLs]. This functionality is
#     considered legacy.'' The term OCSP is not found in the code.
# } 
# Also, it requires that the loghost's certificate and all client
# certificates be signed by the same CA certificate.\footnote{
#     \texttt{/usr/share/doc/rsyslog-4.6.2/ns\_gtls.html} in the
#     \texttt{rsyslog} package: ``Even in x509/fingerprint mode, both the
#     client and sever [sic] certificate currently must be signed by the same
#     root CA. This is an artifact of the underlying GnuTLS library and the way
#     we use it. It is expected that we can resolve this issue in the future.''
#
#     \url{http://www.rsyslog.com/doc/ns_gtls.html} says the same thing as of
#     2011 Jun 09.
#
#     As of Jan 2013, we have \texttt{rsyslog} 5.8.10, and it's the same in
#     this respect.
# }
#
# A loghost set up using this scheme will require hosts which connect to have a
# valid certificate whose common name is a fully qualified DNS name ending in
# the same domain as the loghost. For example, if the loghost is named
# \verb!loghost.example.com!, it will require connecting clients to have certs
# with common names matching the glob \verb!*.example.com!.

class log::rsyslog {
    package { ["rsyslog", "rsyslog-gnutls"]:
        ensure => present,
    }
    service { "rsyslog":
        enable => true,
        ensure => running,
    }

# \implements{unixsrg}{GEN005390,GEN005400,GEN005420} 
# Control ownership and permissions of the \verb!rsyslog! configuration.
#
# Compliance and configuration are mixed here.
    file {
        "/etc/rsyslog.d":
            ensure => directory,
            owner => root, group => 0, mode => 0640,
            recurse => true;
        "/etc/rsyslog.conf":
            owner => root, group => 0, mode => 0640,
            content => "\$IncludeConfig /etc/rsyslog.d/*.conf\n",
            require => File['/etc/rsyslog.d'],
            notify => Service['rsyslog'];
    }

# \implements{unixsrg}{GEN005395} Remove extended ACLs on the \verb!rsyslog!
# configuration.
    no_ext_acl { "/etc/rsyslog.conf": }
    no_ext_acl { "/etc/rsyslog.d": recurse => true }

    define common_conf() {
        file { "/etc/rsyslog.d/${name}":
            owner => root, group => 0, mode => 0640,
            content => template("log/rsyslog/${name}"),
            notify => Service['rsyslog'],
        }
    }
    common_conf {
        "00common-global.conf":;
        "10gnutls-global.conf":;
        "50local.conf":;
    }
}
