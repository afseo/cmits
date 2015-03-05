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
# \subsection{Set MCX values on the computer}
#
# The name must be in the format {\tt
# \emph{appDomain}/\emph{key1}[/\emph{key2}/\emph{key3}...] }.
#
# This defined resource type always uses the record \verb!/Computers/$::fqdn!
# as the place to set the key.
#
# Example:
# \begin{verbatim}
#     mcx::set { "com.apple.digihub/com.apple.digihub.cd.music.appeared":
#         mcx_domain => 'always',
#         value => 1,
#     }
# \end{verbatim}
# \dinkus

define mcx::set($mcx_domain='always', $value, $ensure='present') {
    require mcx::prepare

    mac_mcx_plist_value { "/Computers/${::fqdn}:${name}":
        mcx_domain => $mcx_domain,
        value => $value,
        ensure => $ensure,
    }
}
