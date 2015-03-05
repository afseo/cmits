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
class proxy::pac($url) {
    $safe_osrelease = regsubst(
        $operatingsystemrelease,
        '[^A-Za-z0-9]', '_', 'G')

    class { "proxy::pac::${osfamily}_${safe_osrelease}":
        url => $url,
    }
}
