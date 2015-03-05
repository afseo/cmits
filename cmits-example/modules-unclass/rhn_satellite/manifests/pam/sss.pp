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
# \subsubsection{Use System Security Services (SSS)}

class rhn_satellite::pam::sss {
    augeas { "rhn_satellite_pam_d":
        context => "/files/etc/pam.d/rhn-satellite",
        changes => [
            "rm *",
            "set 1/type    auth",
            "set 1/control required",
            "set 1/module  pam_env.so",
            "set 2/type    auth",
            "set 2/control sufficient",
            "set 2/module  pam_sss.so",
            "set 3/type    auth",
            "set 3/control required",
            "set 3/module  pam_deny.so",
            "set 4/type    account",
            "set 4/control sufficient",
            "set 4/module  pam_sss.so",
            "set 5/type    account",
            "set 5/control required",
            "set 5/module  pam_deny.so",
        ],
    }
}
