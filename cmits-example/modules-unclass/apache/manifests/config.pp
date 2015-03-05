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
# \subsection{Apache configuration}
#
# This submodule configures Apache by editing its configuration files
# with Augeas. The reason for doing this is to make it easier to
# integrate stock Red Hat httpd configuration, configuration required
# for STIG compliance, and configuration for particular kinds of
# websites, as all three change. The most readily apparent simpler
# scheme would be to construct template files for each kind of
# website, and control changes to them separately from this
# \CMITSPolicy . But then a process for doing so would have to be
# worked out (whether formally or not); and tweaking settings for
# compliance rather than replacing them is something already widely
# done here.
#
# So we edit Apache configuration files using Augeas. The Httpd Augeas
# lens defines directives and contexts.
#
# \emph{Contexts} correspond to \verb!<Foo>!  ... \verb!</Foo>! sort
# of constructs in the configuration file. They can contain
# directives.
#
# \emph{Directives} correspond to \verb!Foo bar baz! sort of
# constructs in the configuration file, like \verb!Options None! or
# \verb!Listen 80!.
#
# We define here two resource types to manage these two things. In the
# case where a directive is inside a context, the defined resource
# types include dependencies among themselves so that the context must
# exist before the directive can be set.
#
# \subsubsection{Resource names using context names}
#
# The names of defined resources of these two types are written in a
# peculiar format: {\tt
# \emph{config\_file}:\emph{context\_name\_1}:\emph{context\_name\_2}:...}
# where \emph{config\_file} is the full path name of an Apache
# configuration file; \emph{context\_name\_N} are \emph{names} of
# contexts inside the file (explained below). The rest (\verb!...!) is
# specific to the resource type, \emph{q.v.}.
#
# Context names are used to hook up dependencies among directives and
# contexts, so that if you want a construct of the form
#
# \begin{verbatim}
# <Foo bletch>
#   Bar baz
# </Foo>
# \end{verbatim}
#
# and you make two resources
#
# \begin{verbatim}
# apache::config::context { '/etc/bla/httpd.conf:the_foo':
#     context_in_file => '',
#     type => 'Foo',
#     arguments => ['bletch'],
# }
# apache::config::directive { '/etc/bla/httpd.conf:the_foo:Bar':
#     context_in_file => 'Foo[arg="bletch"]',
#     arguments => ['baz'],
# }
# \end{verbatim}
#
# the directive resource will depend on the context resource without
# your saying anything except to connect them by the
# \emph{context name} \verb!the_foo!. You make up the name; the
# important thing is it's the same between the resources.
#
# FIXME: There is a great deal of semantic overlap between context
# names, which are identifiers that are made up, and contexts inside
# the file, which have special characters but denote a place in the
# file exactly.
#
# \subsubsection{context\_in\_file}
#
# The value of a \verb!context_in_file! parameter is a piece of an
# Augeas context argument. It is tacked onto the end of the path in
# Augeas denoted by the configuration filename ({\tt
# /files/\emph{config\_file}} where \emph{config\_file} is gotten from
# the resource name as above) to denote the place in the Augeas tree
# where a directive or context should be created or controlled. If
# this context should be in the toplevel of the file, not inside
# another angle-bracket-tag sort of thing, \verb!context_in_file!'s
# value should be the empty string.

class apache::config($max_request_body=4194304, $nss_database_dir) {
    class { 'apache::config::httpd_conf':
        max_request_body => $max_request_body,
    }
    class { 'apache::config::nss_conf':
        nss_database_dir => $nss_database_dir,
    }
    file { '/etc/httpd/common':
        ensure => directory,
        owner => root, group => 0, mode => 0600,
        source => 'puppet:///modules/apache/common',
        recurse => true,
        recurselimit => 1,
    }
    # normally this would be a require, but we had to pass some parameters
    Class['apache::config::nss_conf'] -> Class['apache::config']
}
