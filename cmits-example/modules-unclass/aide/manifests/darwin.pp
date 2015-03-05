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
# % This comment is here so that the unimplemented tag below will not
# % be the first non-empty Puppet comment in this file. Shaney puts a
# % \label{.../this_file.pp} after the first line of LaTeX code, but
# % since the unimplemented tag spans multiple lines, that puts the
# % label in the middle of it. That makes the LaTeX angry, and it
# % makes errors that aren't helpful in finding the problem.
#
# \unimplemented{mlionstig}{OSX8-00-01145}{We should watch setuid
# executables on the system. aide is the tool to do this. But we
# haven't implemented it on the Mac yet.}%
class aide::darwin {
    warning 'unimplemented for Macs'
}
