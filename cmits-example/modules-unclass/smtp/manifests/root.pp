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
# \subsection{Mail sent to root}
# \label{root_mail}
#
# Set the place where root's mail goes to. Any service which discovers
# programmatically something the human administrator should know will email
# root, so this should point at a real and capable human. (Examples include
# cron, when output happens, and auditd, when disk space for audit logs runs
# low.)
#
# Example usage:
# \begin{verbatim}
#     smtp::root { "the.real.admin.ctr@example.com": }
# \end{verbatim}
#

define smtp::root() {
    include smtp
# In both cases below we are editing the aliases file. If we change it, we need
# to run newaliases.
    Augeas {
        context => "/files/etc/aliases",
        notify => Exec['newaliases'],
    }
    augeas {
# If there are multiple root entries in the aliases file, delete them: we can't
# properly edit them.
        "aliases_delete_multiple_roots":
            onlyif => "match *[name='root'] size > 1",
            changes => "rm *[name='root']";
# If there is one root entry in the aliases file, make sure it has the right
# value.
        "aliases_set_root":
            onlyif => "match *[name='root'] size == 1",
            changes => "set *[name='root']/value '${name}'";
# If there is no root entry in the aliases file, add one with the right value.
        "aliases_add_root":
            onlyif => "match *[name='root'] size == 0",
            changes => [
                "ins 100000 after *[last()]",
                "set 100000/name root",
                "set 100000/value '${name}'",
            ];
    }
}
