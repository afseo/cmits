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
# \subsection{STIG-required configuration}
#
# Configure iTunes in accordance with the Mac OS X STIG.

class itunes::stig {

# \implements{macosxstig}{OSX00530 M6}%
# \implements{mlionstig}{OSX8-00-01140,OSX8-00-01150,OSX8-00-01155}%
# Disable iTunes Store and other network features of iTunes on Macs.
#
# Note that because this policy uses an MCX object, it imposes this setting on
# every user at once, obviating any actions that must be ``performed for each
# user.''
    mcx::set { [
            'com.apple.iTunes/disableMusicStore',
            'com.apple.iTunes/disablePing',
            'com.apple.iTunes/disablePodcasts',
            'com.apple.iTunes/disableRadio',
            'com.apple.iTunes/disableSharedMusic',
            ]:
        value => true,
    }
}
