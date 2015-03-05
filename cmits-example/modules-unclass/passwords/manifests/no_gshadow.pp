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
# \subsection{Remove passwords from gshadow}

class passwords::no_gshadow {
# We require a custom lens.
    include augeas
# \implements{rhel5stig}{GEN000000-LNX001476} Disable group passwords.
#
# Although \verb!gshadow(5)! says that a password only needs to start with a
# single exclamation point to be invalid, the check listed for this requirement
# only matches double exclamation points. So that the check will succeed, we
# set everything to double exclamation points.
    case $::osfamily {
        RedHat: {
            augeas { 'disable_gshadow_passwords':
                context => '/files/etc/gshadow',
                changes => [
                    'set */password "!!"',
                ],
            }
        }
        default: { unimplemented() }
    }
}
