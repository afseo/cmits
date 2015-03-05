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
# \subsection{World-writable directories}

class stig_misc::world_writable {

# FIXME: You can tell Vagrant to use a different directory than
# \verb!/tmp/vagrant-puppet!; this is just a default; but the code
# below hardcodes it.
    $exceptions = $::vagrant_puppet_provisioning ? {
        'true' => '\! -path /tmp/vagrant-puppet',
        default => '',
    }

# \implements{macosxstig}{GEN002500 M6}%
# \implements{mlionstig}{OSX8-01120}%
# Find and warn administrators about world-writable directories without the
# sticky bit set.
#
# We use \verb!xdev! so as not to traverse onto NFS filesystems---indeed, not
# onto any filesystem other than the root filesystem. On Linux hosts this find
# may not be large enough in scope, but on Macs it should be.
    exec { 'find_non_sticky_world_writable':
        path => ['/bin', '/usr/bin'],
        command => "find / -xdev \
                    -type d -perm -2 \\! -perm -1000 \
                    ${exceptions} \
                    -ls",
        onlyif => "find / -xdev \
                    -type d -perm -2 \\! -perm -1000 \
                    ${exceptions} \
                    -ls  |  grep . >&/dev/null",
        logoutput => true,
        loglevel => err,
    }

# \implements{macosxstig}{GEN002520 M6}%
# \implements{mlionstig}{OSX8-00-01110}%
# Find and warn administrators about public directories not owned by root.
    exec { 'find_public_non_root_owned':
        path => ['/bin', '/usr/bin'],
        command => "find / -xdev \
                    -type d -perm -1002 \\! -user root \
                    -ls",
        onlyif => "find / -xdev \
                    -type d -perm -1002 \\! -user root \
                    -ls  |  grep . >&/dev/null",
        logoutput => true,
        loglevel => err,
    }
}
