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
# \subsection{Deny incoming connections by default}
#
# Any incoming connections controlled by TCP wrappers, which are not explicitly
# allowed, should be denied.

class tcp_wrappers::default_deny {
# We don't need custom Augeas lenses here; but they are needed to
# write things in the \verb!hosts.allow! file, so if we don't have
# them, and we write the \verb!hosts.deny!, nothing will be allowed.
    require augeas
    file { "/etc/hosts.deny":
        owner => root, group => 0, mode => 0644,
        content => "# Deny by default\nALL: ALL\n";
    }
}
