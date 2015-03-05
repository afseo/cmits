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
# \section{PolicyKit}
#
# \subsection{Introduction}
#
# I took a couple hours finding the following out from the PolicyKit
# documentation; hopefully my summary makes it quicker for you, the reader.
#
# PolicyKit finds answers to fine-grained permission questions needed for
# normal desktop operation, like, "Can I mount this USB disk?" or "Can I set
# the WiFi card to use this network?" or "Can I make the computer go to sleep?"
# It does this in a secure fashion. Software authors identify things their
# software needs to do that admins may want to prohibit or restrict, or that
# malware writers may want to trick users into doing. These are defined by XML
# files stored (under RHEL6) in \verb!/usr/share/polkit-1/actions!, one per
# application. These XML files contain defaults given by the software author
# regarding what the policy should be. For example, "by default, users should
# be able to plug in USB disks and have them work."
#
# The PolicyKit local authority listens on the D-Bus for policy questions from
# applications. It consults files under \verb!/etc/polkit-1!,
# \verb!/var/lib/polkit-1! and \verb!/usr/share/polkit-1/actions!. The intent
# is that admins put pieces of overriding policy in \verb!/etc/polkit-1!,
# packagers put pieces of distro-specific overriding policy in
# \verb!/var/lib/polkit-1!, and only software authors mess with what's in
# \verb!/usr/share/polkit-1/actions!. Then the local authority consults these
# files to find the answer to whether someone's allowed to do something.
# Variables include who the user is (user id, group ids), whether the user is
# in possession of the active console session (if the user Switched User rather
# than logging in, there are other users in possession of inactive console
# sessions), and what the action is. Answers may be yes, no, you must type your
# password, or you must authenticate as an admin; part of the answer is how
# long the answer is valid for (this process, this whole session, or forever).
#
# Since PolicyKit policy is split out into separate files, all PolicyKit policy
# is not centralized in this section; different sections of this policy deploy
# bits of PolicyKit policy as needed. Look in the Files index for files with
# \verb!polkit-1! in their pathnames to locate these.
#
#
# \subsection{Policy regarding PolicyKit as a whole}
# 
# Make it harder for non-admins to find out what PolicyKit will let them do.
# The SRG does not require this, but it probably would if they had thought
# about it.
class policykit {
    file { "/etc/polkit-1":
        owner => root, group => 0, mode => 0600,
        recurse => true, recurselimit => 3,
    }
    no_ext_acl { "/etc/polkit-1": recurse => true }
}
