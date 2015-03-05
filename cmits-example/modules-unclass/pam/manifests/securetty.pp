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
# \subsection{securetty}
#
# Install the \verb!pam_securetty! module which prevents root from logging in
# from a tty not explicitly considered secure. See
# also~\S\ref{class_root::login}.

class pam::securetty {
    augeas { "system_auth_securetty":
        context => "/files/etc/pam.d/system-auth",
        changes => [
            "rm *[type='auth'][module='pam_securetty.so']",
# The \verb!pam::faildelay! class (\S\ref{class_pam::faildelay} inserts an
# \verb!auth! module at the beginning of the list, and so does this one.
# Without loss of generality, we will put this one second, so they don't both
# always think the file needs to be edited.
            "ins 100 before *[type='auth' and module!='pam_centrifydc.so'][2]",
            "set 100/type auth",
            "set 100/control required",
            "set 100/module pam_securetty.so",
        ]
    }
}
