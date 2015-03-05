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
class root::only_uid_0::darwin {
# \implements{macosxstig}{GEN000880 M6}%
# \implements{mlionstig}{OSX8-00-01065}%
# Ensure that only root has user id 0.
#
# If the final grep exits without error, it found something. Then we
# run the command and log its output as errors. Because of the onlyif,
# we get no log messages if everything is OK.
    exec { 'warn if other users have uid 0':
        onlyif => 'dscl . -list /Users UniqueID | \
                    grep -w 0 | \
                    grep -v -w ^root',
        command => 'dscl . -list /Users UniqueID | \
                    grep -w 0 | \
                    grep -v -w ^root',
        loglevel => err,
    }
}
