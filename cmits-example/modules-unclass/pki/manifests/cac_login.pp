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
# \subsection{CAC Login}
# \label{pam_cac_login}
#
# \implements{iacontrol}{IATS-1}\implements{unixsrg}{GEN009120}%
# On select hosts, configure the Pluggable Authentication Modules (PAM)
# subsystem to allow CAC login from the console using the {\tt pam\_pkcs11}
# module.
#
# These changes are quite similar to what the command
#
# \begin{verbatim}
# authconfig --enablesmartcard --update
# \end{verbatim}
#
# would do.
#
# Note that as of early 2011, RHEL cannot reliably use Alternate Logon Tokens
# (ALTs) because of a shortcoming in CoolKey; see
# \url{https://bugzilla.redhat.com/show_bug.cgi?id=574953}.

class pki::cac_login {
    augeas { 
        "pam_pkcs11_sa":
            context => "/files/etc/pam.d/system-auth-ac",
            changes => [
# Add the pam\_pkcs11 module to the configuration.
                "ins 100 before \
                     *[module='pam_unix.so'][type='auth']",
                "set 100/type auth",
                "set 100/control '[success=done \
authinfo_unavail=ignore ignore=ignore default=die]'",
                "set 100/module pam_pkcs11.so",
            ],
            onlyif => [
                "match *[module='pam_pkcs11.so'][type='auth'] \
                 size == 0",
            ];
        "pam_pkcs11_arguments_sa":
            require => Augeas["pam_pkcs11_sa"],
            context => "/files/etc/pam.d/system-auth-ac/\
*[module='pam_pkcs11.so'][type='auth']",
            changes => [
                'rm argument',
            ];
            
# Just before it, skip pam\_pkcs11 for all but a few services trying to
# authenticate the user.

        "pam_ignore_pkcs11_sa":
            require => Augeas["pam_pkcs11_sa"],
            context => "/files/etc/pam.d/system-auth-ac",
            changes => [
                "ins 99 before \
                    *[module='pam_pkcs11.so'][type='auth']",
                "set 99/type auth",
                "set 99/control '[success=1 default=ignore]'",
                "set 99/module pam_succeed_if.so",
            ],
            onlyif => [
                "match *[module='pam_succeed_if.so'][type='auth'] \
                 size == 0",
            ];

        "pam_ignore_pkcs11_arguments_sa":
            require => Augeas["pam_ignore_pkcs11_sa"],
            context => "/files/etc/pam.d/system-auth-ac/\
*[module='pam_succeed_if.so'][type='auth']\
[control='[success=1 default=ignore]']",
            changes => [
                "rm argument",
                "set argument[1] service",
                "set argument[2] notin",
# \verb!authconfig! does not enable smartcards for use with sudo, but this
# policy does, by putting sudo in the following list of services.
                "set argument[3] \
login:sudo:gdm:xdm:kdm:xscreensaver:\
gnome-screensaver:kscreensaver",
                "set argument[4] quiet",
                "set argument[5] use_uid",
            ];
    }

# Make sure the CA certs are in place for pam\_pkcs11 to use.
    include pki::ca_certs::pam_pkcs11

# Configure pam\_pkcs11 to look for certificate common names in the GECOS
# field. The pam\_pkcs11 configuration file format is complicated enough that I
# couldn't write an Augeas lens for it within a couple of hours, so we just
# copy the file over.
    file { "/etc/pam_pkcs11/pam_pkcs11.conf":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/pki/pam_pkcs11.conf",
    }
}
