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
# To apply a set of ip6tables rules to a given host (node), first know the
# network and broadcast addresses of the node, and its default gateway. In this
# example we'll say the site is allocated a /48 prefix, and the host has IPv6
# address 2001:DB8:0:3::16. The subnet's address is 2001:DB8:0:3::/64, and the
# whole site's address is 2001:DB8:0::/48. (See
# \href{http://tools.ietf.org/html/rfc3849}{RFC 3849}.) Then you would write:
#
# \begin{verbatim}
#     ip6tables::use { "mytemplate":
#         subnet => "2001:DB8:0:3::/64",
#         site   => "2001:DB8:0::/48",
#     }
# \end{verbatim}
#
# where \verb!mytemplate! is the name of a file in
# \verb!modules/ip6tables/templates! in this policy. \verb!site! is used for
# rules which deal with traffic within a site's (possibly multiple) networks,
# such as SSH connections or pings. 

define ip6tables::use($subnet, $site) {
    include ip6tables
    $ipt_text = template("ip6tables/${name}")
    file { "/etc/sysconfig/ip6tables":
        owner => root, group => 0, mode => 0600,
        content => $ipt_text,
        notify => Service["ip6tables"],
    }
}
