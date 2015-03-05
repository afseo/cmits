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
# \subsection{Show login history}
# 
# \implements{unixsrg}{GEN000452,GEN000454} When a user logs in, show the date
# and time of the user's last successful login, and the number of unsuccessful
# login attempts since the last successful login.
#
# It appears that these requirements are also lodged by AFMAN 33-223.

class stig_misc::login_history {
    include stig_misc::login_history::console
    include stig_misc::login_history::gdm
}
