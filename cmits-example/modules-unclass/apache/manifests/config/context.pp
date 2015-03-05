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
# \subsubsection{Contexts in Apache configuration}
#
# The Httpd Augeas lens defines directives and contexts; contexts
# correspond to \verb!<Foo>! ... \verb!</Foo>! sort of constructs in
# the configuration file. They can contain directives.
#
# The name of resources of this type begins as discussed above, and
# ends with a chosen context name, which must be an identifier (starts
# with a letter, no spaces, no special characters, just letters,
# numbers and underscores). Directive resources whose directives are
# inside this context, and context resources whose contexts are inside
# this context, will include this context name in their resource
# names, so it should be short.
#
# \verb!context_in_file! is as discussed above.
#
# \verb!type! is what kind of angle-bracket-tag sort of thing this
# context should be. Common values for \verb!type! are
# \verb!'Directory'!, \verb!'LimitExcept'!, \verb!'Location'!, and the
# like.
#
# \verb!arguments! is an array of arguments that are written inside
# the angle-brackets. For example, for a \verb!Directory! context, the
# arguments might be \verb!['/var/www']!. The result written in the
# configuration file would look like
#
# \begin{verbatim}
# <Directory /var/www>
# </Directory>
# \end{verbatim}
#
# \dinkus

define apache::config::context(
    $context_in_file, $type, $arguments) {

        include apache
        
        $pieces = split($name, ':')
        $config_file = $pieces[0]
        $parent_context_name = inline_template('<%=@pieces[1..-2].join(":")-%>')
        $this_context_name = $pieces[-1]
    augeas { "add ${name} subcontext ${type} nicknamed ${this_context_name}":
        incl => $config_file,
        lens => 'Httpd.lns',
        context => $context_in_file ? {
            ""      => "/files/${config_file}",
            default => "/files/${config_file}/${context_in_file}",
        },
        changes => inline_template("
clear <%=@type-%>[999]
<% @arguments.each_with_index do |a, zi| %>
set <%=@type-%>[last()]/arg[<%=zi+1-%>] '<%=a-%>'
<% end %>
"),
        onlyif => "match ${type}[arg='${arguments[0]}'] size == 0",
        require => $parent_context_name ? {
            '' => [],
            default => Apache::Config::Context[
                "${config_file}:${parent_context_name}"],
        },
        notify => Service['httpd'],
    }
}
