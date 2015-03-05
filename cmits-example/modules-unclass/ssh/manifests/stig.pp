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
# \subsection{STIG-required SSH configuration}
#
# \implements{unixsrg}{GEN005504}%
# Configure the SSH daemon to listen on addresses other than management network
# addresses, because it is ``authorized for uses other than management'' here.
#
# Either \verb!ssh::gssapi! or \verb!ssh::no_gssapi! must also be included for
# STIG compliance.

class ssh::stig {
    include ssh
    include ssh::fips
    include ssh::no_tunnelling
    include ssh::stig_palatable
}
