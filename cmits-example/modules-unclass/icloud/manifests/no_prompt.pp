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
class icloud::no_prompt {
    define cusa_set($value) {
        mcx::set { "com.apple.SetupAssistant/${name}":
            value => $value,
        }
    }
# \implements{mlionstig}{OSX8-00-01125}%
# Disable the prompt for Apple ID and iCloud for all users (the
# requirement only has to do with new users).
    cusa_set { 'DidSeeCloudSetup': value => true }
    cusa_set { 'LastSeenCloudProductVersion':
        value => $::macosx_productversion,
    }
}
