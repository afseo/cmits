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
# \subsection{Banish a user}
#
# This defined resource type removes all special access for a user from a Trac
# instance. The user will end up being able to do whatever \verb!anonymous! is
# allowed to do inside that Trac instance.
#
# The name is a directory with a Trac instance in it. Example:
# \begin{verbatim}
# trac::banish { '/var/www/tracs/admin':
#     users => ['baduser1', 'baduser2', 'baduser3'],
# }
# \end{verbatim}
#
# \dinkus

define trac::banish($users) {
    trac_permission { 'remove $users from $name':
        instance => $name,
        ensure => absent,
        subject => $users,
        action => [
            "BROWSER_VIEW", "CHANGESET_VIEW", "CONFIG_VIEW",
            "EMAIL_VIEW", "FILE_VIEW", "LOG_VIEW",
            "MILESTONE_ADMIN", "MILESTONE_CREATE",
            "MILESTONE_DELETE", "MILESTONE_MODIFY",
            "MILESTONE_VIEW", "PERMISSION_ADMIN",
            "PERMISSION_GRANT", "PERMISSION_REVOKE",
            "REPORT_ADMIN", "REPORT_CREATE", "REPORT_DELETE",
            "REPORT_MODIFY", "REPORT_SQL_VIEW", "REPORT_VIEW",
            "ROADMAP_ADMIN", "ROADMAP_VIEW", "SEARCH_VIEW",
            "TICKET_ADMIN", "TICKET_APPEND", "TICKET_CHGPROP",
            "TICKET_CREATE", "TICKET_EDIT_CC",
            "TICKET_EDIT_COMMENT", "TICKET_EDIT_DESCRIPTION",
            "TICKET_MODIFY", "TICKET_VIEW", "TIMELINE_VIEW",
            "TRAC_ADMIN", "VERSIONCONTROL_ADMIN",
            "WIKI_ADMIN", "WIKI_CREATE", "WIKI_DELETE",
            "WIKI_MODIFY", "WIKI_RENAME", "WIKI_VIEW",
        ],
    }
}

