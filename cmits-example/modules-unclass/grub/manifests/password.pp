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
# \subsection{Ensure authentication required}
#
# \implements{unixsrg}{GEN008700}%
# Make sure that authentication is required before changing bootloader
# settings.
#
# If you follow the procedures in~\S\ref{Procedures_Provisioning}, you should
# end up with a bootloader password at OS install time. This, then, is either a
# failsafe measure, or a means by which you can easily change bootloader
# passwords across many hosts.
#
# Example invocation:
#
# \begin{verbatim}
# class { 'grub::password':
#     md5_password => 'd3b07384d113edec49eaa6238ad5ff00',
# }
# \end{verbatim}
#
# This results in a line like this in GRUB's configuration:
#
# \begin{verbatim}
# password --md5 d3b07384d113edec49eaa6238ad5ff00
# \end{verbatim}
#
# \dinkus

class grub::password($md5_password) {
    case $::osfamily {
        'RedHat': {
            augeas { "ensure_grub_password":
# Augeas knows how to edit \verb!/etc/grub.conf! but maybe not
# \verb!/boot/grub/menu.lst! or some such: it goes by filename.
                context => '/files/etc/grub.conf',
                changes => [
# Grub's behavior regarding passwords appears to differ depending on where in
# the configuration the password directive is written, but the Augeas lens
# which understands the Grub configuration doesn't make that order information
# easily available to us.
#
# Previously we just set the password, which would insert a password line at
# the end of the Grub configuration if there was no password line already. That
# did the wrong thing. So we get rid of those, if any, and put one at the top
# of the file.
                    "rm password",
                    "ins password before default",
                    "set password '$md5_password'",
                    'clear password/md5',
                ],
            }
        }
# Mac OS X doesn't have grub.        
        'Darwin': {}
        default: { unimplemented() }
    }
}
