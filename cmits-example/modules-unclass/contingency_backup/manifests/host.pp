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
# \subsection{The backup host}
#
# A backup host does the backing up. It needs the ability to send
# messages via SMTP to administrators, an optical drive capable of
# writing, and a printer. It should be a machine to which admins have
# frequent physical access. It must be able to check out the policy
# from the Subversion server non-interactively. And it must have
# elevated access to some NFS shares upon which critical system
# administration data is stored, that it can read some files that only
# root can read, and so that it can write a backup stamp file.
#
# There can and should be more than one backup host. Machinery is built into
# the backup script so that between all backup hosts only one backup will be
# made per month.
#
# Executables necessary to build the CMITS policy must be present and
# runnable by the \verb!nobody! user.

class contingency_backup::host(
    $contingency_backup_url,
    $add_to_path,
    $add_to_pythonpath,
    $stamp_directory,
    ) {
    include common_packages::make
    include common_packages::unix2dos
    include common_packages::latex
    include subversion::pki
    package { [
            'file',
            'dvd+rw-tools',
            'ImageMagick',
            'iadoc',
            'iacic',
# These two are for the empty-optical-disc-awaiter script.
            'pygobject2',
            'dbus-python',
        ]:
        ensure => present,
    }

    file { "/etc/cron.daily/contingency_backup.cron":
        owner => root, group => 0, mode => 0700,
        content => template("contingency_backup/cron.erb"),
    }
}
