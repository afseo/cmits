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
# \subsection{STIG-required RPM package manager configuration}
class rpm::stig($known_unsigned_packages=[]) {
# \implements{unixsrg}{GEN006565} Use the RPM package manager's verify feature
# to cryptographically verify the integrity of installed system software
# monthly.
#
# \implements{iacontrol}{DCSW-1}\implements{databasestig}{DG0021}%
# Use RPM's verify feature to cryptographically verify the integrity of
# installed software for DBMSes included with RHEL.
    file { "/etc/cron.monthly/rpmV.cron":
        owner => root, group => 0, mode => 0700,
        source => "puppet:///modules/rpm/rpmV.cron",
    }
# \implements{unixsrg}{GEN008800} Make sure all packages installed have
# cryptographic signatures.
#
# (\verb!rpm -V! as above will warn about files which have been changed since
# they were installed, but if the installed package is not signed, files from
# an untrusted source could have been installed via the package system.)
#
# Some packages may not be signable. If so, list them in the
# \verb!known_unsigned_packages! parameter to this class. You should
# not share the list of these with the world, because it is a list of
# weaknesses.

    file { "/etc/cron.weekly/rpm-signatures.cron":
        owner => root, group => 0, mode => 0700,
        content => template("rpm/rpm-signatures.cron.erb"),
    }
}
