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
# \subsubsection{Don't necessarily use CACs with Subversion}
#
# This removes the systemwide default to use smartcards with
# Subversion, to enable a use case where some users on a host have
# soft certificates. On such a host, users who wish to use their
# smartcards with Subversion must write a setting for
# \verb!ssl-pkcs11-provider! in their \verb!~/.subversion/servers!
# file.

class subversion::pki::use_smartcard::no {

    include subversion::pki

    require subversion::servers_config
    augeas { 'subversion_use_smartcard':
        context => '/files/etc/subversion/servers/global',
        changes => [
            "rm ssl-pkcs11-provider",
        ],
    }
}
