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
# \subsection{Device files}
#
# \implements{unixsrg}{GEN002260} Check for extraneous device files at least
# weekly.
#
# It appears on RHEL6 that \verb!/dev! is on a different filesystem from
# \verb!/!, so using the \verb!-xdev! switch, in addition to excluding NFS
# filesystems, excludes \verb!/dev!, with the happy result that any device
# files found by this command are extraneous, so no further filtering is
# necessary.

class stig_misc::device_files {
    file { "/etc/cron.weekly/device-files.cron":
        owner => root, group => 0, mode => 0700,
        source => "puppet:///modules/stig_misc/\
device_files/device-files.cron",
    }
}
