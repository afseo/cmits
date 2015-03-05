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
# \subsection{Allow some traffic through TCP wrappers}
#
# Use this like so:
# \begin{verbatim}
#     tcp_wrappers::allow { "sshd":
#         from => [
#             "192.168.122.0/255.255.255.0",
#             "172.16.",
#         ],
#     }
# \end{verbatim}
#
# In keeping with present security guidance regarding TCP wrappers, don't use
# hostnames in the \verb!from! parameter, because attackers may try to poison
# DNS.
#
# TCP wrappers do not appear to support CIDR notation (\verb!192.168.122.0/24!)
# for IPv4 at this time.

define tcp_wrappers::allow($from) {
    include tcp_wrappers::default_deny
    require tcp_wrappers::hosts_allow

# Here follows technical discussion about the specific way we are
# editing the file.
#
# According to tests in July 2013, if the \emph{single} value of the
# \verb!changes!  parameter to the \verb!augeas! resource type has
# newlines, each line in the value is treated as a separate command
# for Augeas. It's not really easy in Puppet 2.7 to take a list of
# values, turn it into another list of values and concatenate it to
# another list. But we can easily take a list and turn it into a
# string containing newlines using \verb!inline_template!.
#
# The reason this is so involved, as compared to some
# insert-then-change sorts of rules in the \verb!pam! module
# (\S\ref{module_pam}), is that an entry with only a process and no
# clients is not valid under the Augeas lens we are using, so you
# can't add the process if it doesn't exist, then set up the clients,
# you have to add the process and setup the clients if there's no
# entry, or just make sure the clients are set right if there is an
# entry.
#
# The reason to avoid just nuking the entry if it exists, then
# recreating it, is that that operation doesn't preserve the order of
# the entries in the file, and so if we are allowing access to
# multiple services, we keep deleting and inserting lines, reshuffling
# the file and never leaving it alone.
#
# If the entry doesn't exist, we need to add it---
    $add_entry = inline_template("
set 999/process '<%=@name-%>'
defvar n 999
")

# If it does, we need to point our n variable at it.
    $ref_entry = inline_template("
defvar n *[process='<%=@name-%>']
")

    $already_exists_changes = inline_template("
rm \$n/client
<% if @from.is_a? Array;
      @from.each do |client_netmask|
        client, netmask = client_netmask.split('/') %>
set \$n/client[last()+1]         '<%=client-%>'
<%      if netmask %>
set \$n/client[last()  ]/netmask '<%=netmask-%>'
<%      end %>
<%    end
   else
      client, netmask = @from.split('/') %>
set \$n/client[last()+1]         '<%=client-%>'
<%    if netmask %>
set \$n/client[last()  ]/netmask '<%=netmask-%>'
<%    end %>
<% end %>
")

# Non-stock Augeas lens may be required.
    require augeas

    Augeas {
        context => '/files/etc/hosts.allow',
    }

    augeas { "hosts_allow_add_${name}":
        changes => inline_template("
<%=@add_entry-%>
<%=@already_exists_changes-%>
"),
        onlyif => "match *[process='${name}'] size == 0",
    }

    augeas { "hosts_allow_modify_${name}":
        changes => inline_template("
<%=@ref_entry-%>
<%=@already_exists_changes-%>
"),
        onlyif => "match *[process='${name}'] size > 0",
    }
}
