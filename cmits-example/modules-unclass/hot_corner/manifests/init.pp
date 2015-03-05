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
# \subsection{Hot corners}
#
# Configure ``hot corners'' on Macs, that is, actions that happen when the
# mouse pointer is moved to a corner of the screen and left there for a couple
# of seconds.
#
# The \verb!hot_corner! resource defined below makes a computer-wide policy for
# what action should be attached to one of the corners of the screen.
#
# The name of a \verb!hot_corner! resource is one of the four strings
# \verb!tl!, \verb!tr!, \verb!bl! or \verb!br!, denoting which corner of the
# screen we're talking about.
# \verb!action! is one of the keys in the settings hash below.
#
# Example:
# \begin{verbatim}
#   hot_corner { 'tl':
# \end{verbatim}
# \dinkus

define hot_corner($action) {


# These settings were derived under Snow Leopard by changing the settings in
# System Preferences, and reading them out using \verb!defaults(1)!.
    $settings = {
        'nothing'             => 1,
        'all-windows'         => 2,
        'application-windows' => 3,
        'desktop'             => 4,
        'dashboard'           => 7,
        'spaces'              => 8,
        'start-screensaver'   => 5,
# Don't configure any of the corners to disable the screensaver. Don't.
 #          'disable-screensaver' => 6,
        'sleep-display'       => 10,
    }

    mcx::set { "com.apple.dock/wvous-${name}-corner":
        value => $settings[$action],
    }

# Not sure exactly what the modifier means; this is just what showed up in the
# \verb!defaults(1)! when a corner was set to no action.
    mcx::set { "com.apple.dock/wvous-${name}-modifier":
        value => $action ? {
            'nothing' => 1048576,
            default   => 0,
        },
    }
}

