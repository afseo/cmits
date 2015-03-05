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
# \section{MCX}
# 
# Manage per-user or per-computer settings on Macs using MCX (acronym expansion
# unknown).
#
# Puppet provides an \verb!mcx! resource type, which ``manages the entire
# MCXSettings attribute available to some directory services nodes.'' According
# to
# \href{https://groups.google.com/d/msg/puppet-users/aYU7fZU6tw8/9ybJTePGnYgJ}{a
# mailing list message from October 2009}, this is because there are ``many
# nested values that would be impossible to neatly specify in the puppet DSL.'' 
# The best guide so far for how to manage MCX using the \verb!mcx! resource
# type is at
# \url{http://flybyproduct.carlcaum.com/2010/03/managing-mcx-with-puppet-on-snow.html}.
#
# With all that said, this module does not use the \verb!mcx! resource type:
# here we try to manage in more detail, so that settings needed for one reason
# or another can be written in the place in this \CMITSPolicy\ where they
# logically belong, rather than being jumbled together into one big pot of
# settings.
