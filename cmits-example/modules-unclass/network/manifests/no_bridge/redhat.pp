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
class network::no_bridge::redhat {
# Make sure we have \verb!brctl!.
    package { "bridge-utils":
        ensure => present,
    }
# Use it to make sure there are no bridges in operation.
    exec { "no_bridges":
        path => "/bin:/sbin:/usr/bin:/usr/sbin",
# \verb!brctl show! always shows a header; skip it. After that, if there are
# any lines of output, we have a situation.
        onlyif => "test `brctl show | tail -n +2 | wc -l` -ne 0",
        command => "echo ETHERNET BRIDGING CONFIGURED; \
                    brctl show",
        logoutput => true,
        loglevel => err,
    }
}
