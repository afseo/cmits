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
# \section{Configure PAM}
#
# As of this writing, most PAM configuration happens outside this section, but
# at some point it will be brought together.
#
# \unimplemented{rhel5stig}{GEN000000-LNX00600}{This requirement deserves a hard
# look. It appears from a reading of the manual pages that the
# pam\_console PAM module has little, if anything, to do with the
# asserted vulnerability. If that is true, disabling it would not result in the
# security outcome claimed; meanwhile, disabling it would have serious
# usability consequences.}
