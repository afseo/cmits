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
# \section{Managing GPG keys in the RPM database}
#
# This defined resource type can manage GPG keys used to sign RPM
# packages.
#
# Example:
# \begin{verbatim}
# rpm::gpgkey { 'd3adb33f': source => 'http://myserver/pub/d3adb33f.key' }
# \end{verbatim}
#
# The name should be an eight-digit hexadecimal number, the key
# identifier; the source can be anything that \verb!rpm --import!
# understands, like an http URL, or an absolute path to a file that
# exists and contains the GPG public key. For the optional ensure
# parameter you can give values `present' or `absent'; it defaults to
# `present'.

define rpm::gpgkey($source, $ensure='present') {
    case $ensure {
        'present': {
            exec { "import rpm gpg key ${name}":
                command => "rpm --import ${source}",
                unless => "rpm -q gpg-pubkey-${name}",
            }
        }
        'absent': {
            exec { "remove rpm gpg key ${name}":
                command => "rpm -e gpg-pubkey-${name}",
                onlyif => "rpm -q gpg-pubkey-${name}",
            }
        }
    }
}
