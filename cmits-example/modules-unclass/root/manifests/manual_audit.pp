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
# \subsection{Ask those logging in as root who they are}
#
# In order to preserve auditability even though \verb!root! is a group
# authenticator, ask users logging in as root who they are.
#
# Note that this has to be portable across all the platforms we use
# bash on.

class root::manual_audit {
    $bashrc = '/root/.bashrc'
    exec { 'add challenge 1 to root .bashrc':
        command => "sed -i.before_manual_audit -e '\$a \\
# % vvv puppet root::manual_audit 1 vvv\\
trap '\\'\\'' SIGINT\\
echo\\
echo \"Who are you and what are you doing?\"\\
echo \"Press Ctrl-D on an empty line when finished explaining.\"\\
sed '\\''s/[[:cntrl:]]/(CONTROL CHAR)/g'\\'' | \\\\\\
    logger -t \"ROOT LOGIN, user said\"\\
echo \"What you typed has been logged. Continuing.\"\\
trap - SIGINT\\
# % ^^^ puppet root::manual_audit 1 ^^^
' ${bashrc}",
        unless => "grep 'root::manual_audit 1 ' ${bashrc}",
        path => '/bin:/sbin',
    }
}
