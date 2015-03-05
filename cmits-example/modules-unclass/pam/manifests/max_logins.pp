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
# \subsection{Limit maximum logins}
#
# \implements{iacontrol}{ECLO-1} Configure the system to limit the maximum
# number of logins.
#
# Note that each terminal window opened by a user may consume a login, so if
# you have more than \verb!$limit! terminal windows open, and then you go to
# another host, and try to \verb!ssh! to your workstation, you could be denied.

class pam::max_logins($limit=10) {

# This is done by means of \verb!pam_limits.so!. Make sure it's in place.
    include pam::limits

# Now---\verb!pam_limits.so! gets its list of limits from a configuration file.
# Make sure that file says that everyone has a maxlogins of 10.
    augeas {
        "limits_insert_maxlogins":
            context => "/files/etc/security/limits.conf",
            onlyif => "match *[.='*' and item='maxlogins']\
                             size == 0",
            changes => [
                "insert domain after *[last()]",
                "set domain[last()] '*'",
                "set domain[last()]/type hard",
                "set domain[last()]/item maxlogins",
                "set domain[last()]/value ${limit}",
            ];
        "limits_set_maxlogins":
            require => Augeas["limits_insert_maxlogins"],
            context => "/files/etc/security/limits.conf",
            changes => [
                "set domain[.='*' and item='maxlogins']/type hard",
                "set domain[.='*' and item='maxlogins']/value ${limit}",
            ];
    }
}
