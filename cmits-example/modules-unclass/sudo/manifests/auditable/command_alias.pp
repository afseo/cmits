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
# \subsubsection{Command aliases}
#
# This defined resource type sets up a command alias in the sudo
# configuration. It's quite a thin layer over the \verb!sudoers(5)!
# syntax. When you see a strange-looking word written in
# \verb!fixed type! in this section, look for its meaning in the
# man page.
#
# The \verb!commands! parameter is a list of \verb!Cmnd!s.
#
# The \verb!type! parameter is one of \verb!noexec!, \verb!exec!,
# \verb!setenv_noexec!, or \verb!setenv_exec!. The meanings of these
# terms are to be found in \verb!sudoers(5)! by searching for the term
# \verb!Tag_Spec!.
#
# If enable is false, the command alias will have a bang in front of
# its name when it is included in the configuration, with the effect
# that the commands given will be disallowed instead of being
# allowed. See {\tt Other special characters and reserved words} in
# the man page.

define sudo::auditable::command_alias(
    $commands,
    $type='noexec',
    $enable=true,
    ) {

    sudo::policy_file { "30${name}":
        content => inline_template("
Cmnd_Alias <%=@name%> = \\
    <%=[*@commands].join(', ')%>
"),
    }

    $prefixed_type = $enable ? {
        true    => $type,
        default => "DISALLOW_${type}",
    }

    require sudo::auditable::whole
    datacat_fragment { "command_alias ${name}":
        target => "sudoers.d/90auditable_whole",
        data => {
            "$prefixed_type" => [$name,],
        },
    }
}
