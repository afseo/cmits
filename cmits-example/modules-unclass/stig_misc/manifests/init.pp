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
# \section{Miscellaneous STIG requirements}
#
# STIG-related configuration that has to do with sizable subsystems is placed
# under those subsystems; this section contains policies which are simple,
# small, and unlikely to interfere with any site-specific configuration.

class stig_misc {
    include stig_misc::host_based_authn

    case $::osfamily {
        'RedHat': {
# \implements{unixsrg}{GEN001100} Prevent unencrypted terminal access by
# uninstalling \verb!rsh! and \verb!telnet!.
            include rsh::no
            include telnet::no

# \implements{unixsrg}{GEN003860} Remove the finger server.
            package {
                "finger-server": ensure => absent;
            }

# \unimplemented{unixsrg}{GEN000450}{The STIG requires to limit users
# to 10 simultaneous logins. Many people here, including Jared, run
# more than 10 xterms routinely, each of which is a ``login''; logging
# in using ssh fails if the maximum logins are not set high enough.}
            class { 'pam::max_logins':
                limit => 30,
            }

# \implements{unixsrg}{GEN000480} Make the system delay at least 4 seconds
# following a failed login.
            class { 'pam::faildelay':
                seconds => 4,
            }

            include stig_misc::login_history
            include stig_misc::permissions
            include stig_misc::startup_files
            include stig_misc::system_files
            include stig_misc::library_files
            include stig_misc::man_page_files
            include stig_misc::skel
            include stig_misc::xinetd
            include stig_misc::run_control_scripts
            include stig_misc::device_files
            include stig_misc::find_uneven
            include stig_misc::world_writable
        }
# The Mac OS X STIG stuff is all taken care of elsewhere.
        'Darwin': {}
        default: { unimplemented() }
    }
}
