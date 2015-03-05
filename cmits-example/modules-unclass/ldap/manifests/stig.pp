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
# \subsection{STIG-required LDAP configuration}

class ldap::stig {

# \implements{macosxstig}{GEN008060 M6,GEN008080 M6,GEN008100 M6}%
# \implements{unixsrg}{GEN008060,GEN008080,GEN008100}%
# Control ownership and permissions of \verb!ldap.conf!.
    $ldap_conf = $::osfamily ? {
        'redhat' => '/etc/ldap.conf',
        'darwin' => '/etc/openldap/ldap.conf',
        default  => unimplemented,
    }
    file { $ldap_conf:
        owner => root, group => 0, mode => 0644,
    }

# \implements{macosxstig}{GEN008120 M6}%
# \implements{unixsrg}{GEN008120}%
# Remove extended ACLs on \verb!ldap.conf!.
    no_ext_acl { $ldap_conf: }

# \notapplicable{unixsrg}{GEN008140,GEN008160,GEN008180,GEN008200}%
# \notapplicable{unixsrg}{GEN008220,GEN008240,GEN008260,GEN008280}%
# \notapplicable{unixsrg}{GEN008300,GEN008320,GEN008340,GEN008360}%
# This policy presently does not configure an LDAP client.

}
