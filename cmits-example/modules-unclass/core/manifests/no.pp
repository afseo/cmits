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
# \subsection{Turn off core dumps}
#
# \implements{unixsrg}{GEN003500}%
# Turn off core dumps because we do not need them.

class core::no {
    case $::osfamily {
        'RedHat': {
# This is done by means of \verb!pam_limits.so!. Make sure it's in place.
            include pam::limits

# Now configure \verb!pam_limits.so!. (See \S\ref{class_pam::max_logins}
# for another example.)
            augeas {
                "limits_insert_core":
                    context => "/files/etc/security/limits.conf",
                    onlyif => "match *[.='*' and item='core']\
                                     size == 0",
                    changes => [
                        "insert domain after *[last()]",
                        "set domain[last()] '*'",
                        "set domain[last()]/type hard",
                        "set domain[last()]/item core",
                        "set domain[last()]/value 0",
                    ];
                "limits_set_core":
                    require => Augeas["limits_insert_core"],
                    context => "/files/etc/security/limits.conf",
                    changes => [
                        "set domain[.='*' and item='core']/type hard",
                        "set domain[.='*' and item='core']/value 10",
                    ];
            }
        }
        'Darwin': {}
        default: { unimplemented() }
    }
}
        

# \notapplicable{unixsrg}{GEN003501,GEN003502,GEN003503,GEN003504,GEN003505}%
# With no core dumps, there is no centralized directory where core dumps are
# stored, so such a directory need not be secured.
