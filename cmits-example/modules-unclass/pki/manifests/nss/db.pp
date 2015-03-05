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
# \subsection{NSS databases}
#
# Some subsystems store their CA certificates in an NSS database rather than a
# directory. Here is how to ensure that such an NSS database exists and is
# ready to have certificates imported into it.
#
# The \verb!pwfile! parameter dictates whether to create a password file along
# with the database. For specific services this may be necessary; for managing
# the systemwide NSS database it should be false.

define pki::nss::db($owner, $group, $mode, $sqlite=true, $pwfile=false) {
    $dbdir = $sqlite ? {
        true  => "sql:${name}",
        false => $name,
    }
    $creates = $sqlite ? {
        true  => "${name}/cert9.db",
        false => "${name}/cert8.db",
    }
# Every NSS database is a directory containing several \verb!.db! files, and is
# referred to using the name of the directory. First, make sure the directory
# exists.
    file { "$name":
        ensure => directory,
        owner => $owner, group => $group, mode => $mode,
        recurse => true,
        recurselimit => 1,
    }
# Then, if there is no certificate database file in the directory, create it.
    case $pwfile {
        true: {
# \emph{certutil} needs the password file, and other automated NSS management
# by Puppet needs the password file; but on production servers the password
# should be saved somewhere and the password file should be deleted, so that
# using the NSS database set up here will require the passphrase to be entered.
            pki::nss::pwfile { "${name}":
                require => File["${name}"],
            } ->
            exec { "create_nssdb_${name}_with_pwfile":
                command => "/usr/bin/certutil \
                    -N -d ${dbdir} -f ${name}/pwfile",
                creates => $creates,
            } ~> # squiggle not dash
            exec { "enable_fips_${name}_with_pwfile":
                refreshonly => true,
                command => "/usr/bin/modutil \
                    -dbdir ${dbdir} \
                    -fips true",
            }
        }
        default: {
# We use \verb!modutil! to create the database. \verb!certutil! would work too,
# but it needs a passphrase.
            exec { "create_nssdb_${name}":
                command => "/usr/bin/modutil \
                    -create \
                    -dbdir ${dbdir} \
                    </dev/null >&/dev/null",
# The redirections get rid of \verb!modutil!'s warning about modifying the
# database while ``the browser is running.'' In a systemwide context this
# doesn't matter.
                require => File["$name"],
                creates => $creates,
            }
# We don't turn on FIPS mode because that would require a password
# before the database could be used, and we didn't set up a password
# file.
        }
    }
}

# In other PKI subsections the above define is used to automate these checks.
