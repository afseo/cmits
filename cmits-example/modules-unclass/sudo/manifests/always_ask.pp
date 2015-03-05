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
# \subsection{Always ask for password when sudoing}

class sudo::always_ask {
# The check content in the STIG says to look for these two ``Defaults'' lines
# in \verb!/etc/sudoers!; we have written them in a file under
# \verb!/etc/sudoers.d! instead. So while we are compliant, the check as it
# stands will fail.
#
# \implements{macosxstig}{OSX00110 M6}%
# Always ask for passwords when people use sudo.
#
# The Rule Title here does not correctly summarize what the Vulnerability
# Discussion, Check Content and Fix Text describe.
    sudo::policy_file { 'always_ask':
        content => "
Defaults tty_tickets
Defaults timestamp_timeout=0
",
    }
}
