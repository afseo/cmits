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
# \subsection{Remove sharepoint groups}
#
# There are some ``sharepoint'' groups on any given Mac, which have
# something to do with sharing folders over the network (not with
# Microsoft Sharepoint). We don't share folders from our Macs, only
# from our filers, so we don't need membership in these groups. But we
# do have many other groups. NFSv3 has a sixteen-group limit, and some
# of our users have nearly sixteen groups that it's important they be
# in. The sharepoint groups count against that maximum, and they
# contain the \verb!everyone! group nested inside them, so here we
# remove that so to free up groups for our users.

class mac_local_groups::remove_sharepoints {
    define remove_everyone_from() {
        $everyone_uuid = "ABCDEFAB-CDEF-ABCD-EFAB-CDEF0000000C"
        exec { "remove everyone from ${name}":
            onlyif => "/usr/bin/dscl . \
                           -read /Groups/${name} NestedGroups | \
                       /usr/bin/grep ${everyone_uuid} >&/dev/null",
            command => "/usr/bin/dscl . \
                           -delete /Groups/${name} NestedGroups \
                                   ${everyone_uuid}",
        }
    }
    remove_everyone_from { 'com.apple.sharepoint.group.2': }
    remove_everyone_from { 'com.apple.sharepoint.group.3': }
}
