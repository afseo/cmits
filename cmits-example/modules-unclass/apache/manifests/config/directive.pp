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
# \subsubsection{Directives in Apache configuration}
#
# The name of resources of this type begins as discussed above, and
# ends with the name of a directive, like \verb!Options! or
# \verb!NSSUserName! or \verb!Listen!.
#
# The \verb!context_in_file! parameter is as discussed above.
#
# \verb!arguments! is an array of arguments that are written after the
# name of the directive; for example, if you wanted a directive that
# says \verb!Deny from all!, \verb!arguments! should be set to
# \verb!['from', 'all']!.

define apache::config::directive(
    $context_in_file, $arguments) {

    include apache
    $pieces = split($name, ':')
    $config_file = $pieces[0]
    $directive = $pieces[-1]
    $context_name = inline_template('<%=@pieces[1..-2].join(":")-%>')
    $context_for_d = $context_in_file ? {
        ''      => "/files/${config_file}",
        default => "/files/${config_file}/${context_in_file}",
    }
    Augeas {
        incl => $config_file,
        lens => 'Httpd.lns',
        notify => Service['httpd']
    }
    $replace_args = inline_template("
rm arg
<% @arguments.each_with_index do |a, zi| %>
set arg[<%=zi+1-%>] '<%=a-%>'
<% end %>
")
    augeas { "add ${name}":
	context => $context_for_d,
	changes => "set directive[999] '${directive}'",
	onlyif => "match directive[.='${directive}'] size == 0",
        require => $context_name ? {
            '' => [],
            default    => Apache::Config::Context[
                "${config_file}:${context_name}"],
        },
    } ->
    augeas { "correct ${name}":
	context => "${context_for_d}/directive[.='${directive}']",
	changes => $replace_args,
    }
}
