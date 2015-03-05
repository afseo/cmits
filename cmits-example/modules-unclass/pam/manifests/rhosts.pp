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
# \subsection{Disable rhosts in PAM}
class pam::rhosts {
# \implements{unixsrg}{GEN002100} Make sure the \verb!.rhosts! file is not
# supported in PAM.
    augeas { "system_auth_no_rhosts":
        context => "/files/etc/pam.d/system-auth",
        changes => "rm *[module='pam_rhosts.so']",
    }
}
