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
# \section{nodes.pp}
# \label{nodes}
#
# Here is the definition of each node known in this policy. (A \emph{node} is
# any host which runs Puppet, virtual or physical.) Classes included here will
# be defined in \S\ref{templates}.

import "templates"

node example1 {
    include example_org_workstation
}

