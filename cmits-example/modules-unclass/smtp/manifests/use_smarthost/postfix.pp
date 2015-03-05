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
# \subsubsection{Setting the smart host when using Postfix}

define smtp::use_smarthost::postfix() {
    include smtp::postfix
    augeas { "postfix use smarthost":
        context => '/files/etc/postfix/main.cf',
        changes => "set relayhost '${name}'",
        notify => Service['postfix'],
    }
}
