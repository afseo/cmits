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
# \subsection{Smart hosts}
#
# A \emph{smart host}, or \emph{relay host}, is a mail server through which all
# outgoing mail should be routed. The smart host, then, is the host that
# connects to a destination mail server to deliver the mail, not the host where
# the mail originated. This is useful in cases where the originating host is
# behind some sort of firewall and cannot connect to destination mail servers
# itself.
#
# This is a defined resource type so that it can be exported and collected.

define smtp::use_smarthost() {
    case $::osfamily {
        'RedHat': {
            case $::operatingsystemrelease {
                /^6\..*/: {
                    smtp::use_smarthost::postfix { $name: }
                }
                default: { unimplemented() }
            }
        }
        default: { unimplemented() }
    }
}
