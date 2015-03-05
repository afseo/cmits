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
# \subsubsection{Insecure NSS password files}
#
# This defined resource type generates an NSS password file in the named
# database directory containing a random password. It's for use on development
# servers, which we want to be able to set up with less hands-on
# administration.
#
# This code does not deal with changing the password every year.

define pki::nss::pwfile($filename='pwfile') {
    exec { "create ${name}/${filename}":
        command => "bash -c \"\
            PW=$(head -c 24 /dev/random | base64 -); \
            for m in internal 'NSS Certificate DB' \
                    'NSS FIPS 140-2 Certificate DB'; do
                echo \\\"\\\$m:\\\$PW\\\"; done > ${name}/${filename}\"",
        path => ['/bin', '/usr/bin'],
        creates => "${name}/${filename}",
    }
}
