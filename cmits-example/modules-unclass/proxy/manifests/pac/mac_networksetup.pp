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
# \subsubsection{Set proxy autoconfiguration URL on Macs using networksetup}

class proxy::pac::mac_networksetup($url) {

# Examples of network services are \verb!Ethernet! and \verb!AirPort!.
    $networkservice = 'Ethernet'

    exec { 'set Mac autoproxyurl':
        unless => "networksetup -getautoproxyurl ${networkservice} | \
                   grep \"URL: ${url}\"",
        command => "networksetup -setautoproxyurl ${networkservice} ${url}",
    }

    exec { 'enable Mac autoproxy':
        onlyif => "networksetup -getautoproxyurl ${networkservice} | \
                   grep \"Enabled: no\"",
        command => "networksetup -setautoproxystate ${networkservice} on",
    }
}
