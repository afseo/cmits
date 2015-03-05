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
# \subsubsection{libpurple (Pidgin)}
#
# Install CA certs into the /usr/share/purple/ca-certs directory, where they
# will be used by instant messaging clients that use the {\tt libpurple}
# library.

class pki::ca_certs::libpurple {
    # This method seems janky.
    define install() {
        $cacerts = $::osfamily ? {
            'RedHat' => '/usr/share/purple/ca-certs',
            default  => unimplemented(),
        }
        file { "$cacerts/$name":
            owner => root, group => 0, mode => 0444,
            source => "puppet:///modules/pki/all-ca-certs/$name",
            require => Package['libpurple'],
        }
    }
    define remove() {
        $cacerts = $::osfamily ? {
            'RedHat' => '/usr/share/purple/ca-certs',
            default  => unimplemented(),
        }
        file { "$cacerts/$name":
            ensure => absent,
            require => Package['libpurple'],
        }
    }
    install { [
            'DoD-email-Root2-CA21.crt',
            'DoD-email-Root2-CA22.crt',
            'DoD-email-Root2-CA23.crt',
            'DoD-email-Root2-CA24.crt',
            'DoD-email-Root2-CA25.crt',
            'DoD-email-Root2-CA26.crt',
            'DoD-email-Root2-CA27.crt',
            'DoD-email-Root2-CA28.crt',
            'DoD-email-Root2-CA29.crt',
            'DoD-email-Root2-CA30.crt',
            'DoD-Root2-CA21.crt',
            'DoD-Root2-CA22.crt',
            'DoD-Root2-CA23.crt',
            'DoD-Root2-CA24.crt',
            'DoD-Root2-CA25.crt',
            'DoD-Root2-CA26.crt',
            'DoD-Root2-CA27.crt',
            'DoD-Root2-CA28.crt',
            'DoD-Root2-CA29.crt',
            'DoD-Root2-CA30.crt',
            'DoD-Root2-Root.crt',
            'ECA-IdenTrust3.crt',
            'ECA-ORC-HW4.crt',
            'ECA-ORC-SW4.crt',
            'ECA-Root2.crt',
            'ECA-Root.crt',
            'ECA-Verisign-G3.crt',
        ]: }
    remove { [
            'DoD-Class3-Root.crt',
            'DoD-email-Root2-CA15.crt',
            'DoD-email-Root2-CA16.crt',
            'DoD-email-Root2-CA17.crt',
            'DoD-email-Root2-CA18.crt',
            'DoD-email-Root2-CA19.crt',
            'DoD-email-Root2-CA20.crt',
            'DoD-Root2-CA15.crt',
            'DoD-Root2-CA16.crt',
            'DoD-Root2-CA17.crt',
            'DoD-Root2-CA18.crt',
            'DoD-Root2-CA19.crt',
            'DoD-Root2-CA20.crt',
            'ECA-IdenTrust2.crt',
            'ECA-Verisign-G2.crt',
            'ECA-ORC-HW3.crt',
            'ECA-ORC-SW3.crt',
        ]: }
}
