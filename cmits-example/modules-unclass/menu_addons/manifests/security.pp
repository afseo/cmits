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
# \subsection{Security menu}
#
# The biggest reason to enable this is that the menu it makes
# available has a ``Lock Screen'' item on it.

class menu_addons::security {
    $kcaccess = '/Applications/Utilities/Keychain Access.app'
    $filename = "${kcaccess}/Contents/Resources/Keychain.menu"
    mcx::set { "com.apple.mcxMenuExtras:${filename}":
        value => true,
    }
}
