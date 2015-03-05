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
class core::stig::darwin {
    $core_dir = '/Library/Logs/DiagnosticReports'
    file { $core_dir:
# \implements{mlionstig}{OSX8-00-01175}%
# Ensure root owns the centralized core dump data directory.
# \implements{mlionstig}{OSX0-00-01185}%
# Ensure the group admin owns the centralized core dump data
# directory.
        owner => root, group => admin,
# \implements{mlionstig}{OSX8-00-01180}%
# Ensure restrictive permissions on the centralized core dump data
# directory.
        mode => 0750,
    }
}
