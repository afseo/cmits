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
# \section{LDAP}
#
# We do not presently use the Lightweight Directory Access Protocol (LDAP) for
# authentication, but if we did, we would have to implement these requirements:
#
# \notapplicable{unixsrg}{GEN007970,GEN007980,GEN008000}%
# \notapplicable{unixsrg}{GEN008020,GEN008040,GEN008050}%
# Systems using LDAP for authentication or account information must use
# FIPS-approved means for constructing a TLS connection, use DoD-signed
# certificates to authenticate themselves and the server, and check for trust
# and revocation of the server certificate. Use this PKI-based method or
# Kerberos, not storage of a password, to authenticate LDAP client hosts.
#
# \notapplicable{macosxstig}{OSX00115 M6,OSX00120 M6,OSX00125 M6}%
# \notapplicable{macosxstig}{OSX00121 M6,OSX00122 M6,OSX00123 M6,OSX00124 M6}%
# Macs using LDAP must be ``securely configured'' in a variety of ways.
