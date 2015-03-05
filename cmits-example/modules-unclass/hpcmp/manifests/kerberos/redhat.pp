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
class hpcmp::kerberos::redhat {
    package { 'hpc_krb5':
        ensure => present,
    }

# If we're using some other form of Kerberos, the \verb!/etc/krb5.conf! file
# may be automatically, repeatedly overwritten with settings not useful to us
# in getting HPCMP Kerberos tickets. So we want to explicitly use an
# HPCMP-specific configuration when doing HPCMP Kerberos.
    file { '/etc/profile.d/hpc_krb5.sh':
        owner => bin, group => 0, mode => 0444,
        content => "\
hpc_krb5=/usr/local/hpc_krb5
export PATH=\$hpc_krb5/bin:\$PATH
alias pkinit=\"KRB5_CONFIG=\$hpc_krb5/etc/krb5.conf \\\n\
                pkinit \"\n\
",
    }
# We need DoD root and CA certificates. These are off in the pki module so that
# we can have only one copy of the certificates.
    include pki::ca_certs::pkinit
}
