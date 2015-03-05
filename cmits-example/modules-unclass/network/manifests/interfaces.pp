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
# \subsection{Interfaces}
#
# Use Facter to figure out which interfaces we're using. Assume the first one
# is the one we should configure. Facter takes care of filtering out \verb!lo!,
# the loopback interface.
class network::interfaces {
# The \verb!$interfaces! variable is a string with all the interfaces separated
# by commas. First turn it into an array...
    $all = split($interfaces,",")
# then pick out the first member.
    $first = $all[0]
}
