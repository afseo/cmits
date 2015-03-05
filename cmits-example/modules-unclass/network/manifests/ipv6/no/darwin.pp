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
# \paragraph{Turn off IPv6 under Mac OS X}

class network::ipv6::no::darwin {

# \implements{mlionstig}{OSX8-00-01240}%
# Turn off IPv6 ``if not being used.''
    define on_interface() {
        exec { "turn off IPv6 on ${name}":
            command => "networksetup -setv6off ${name}",
            unless => "networksetup -getinfo ${name} | \
                       grep '^IPv6: Off\$'",
        }
    }
    on_interface { 'Ethernet': }
}
