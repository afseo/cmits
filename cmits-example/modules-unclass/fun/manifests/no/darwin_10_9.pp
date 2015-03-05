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
class fun::no::darwin_10_9 {

# \implements{mlionstig}{OSX8-00-00470}%
# Remove the Chess application from Macs.
    file { '/Applications/Chess.app':
        ensure => absent,
        recurse => true,
        force => true,
    }
# \implements{mlionstig}{OSX8-00-00480}%
# Remove the Game Center application from Macs.
    file { '/Applications/Game Center.app':
        ensure => absent,
        recurse => true,
        force => true,
    }

# \notapplicable{mlionstig}{OSX8-00-00481}%
# ``This requirement is N/A if requirement \mlionstig{OSX8-00-00480} is
# met.''
}
