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
# \subsection{NFS mounts}
#
# To make sure of a certain filesystem being mounted, call this define like so:
#
# {\tt automount::mount \{ \emph{name}: from => "\emph{nfs path}" \}}
#
# For example, {\tt automount::mount \{ "home": from =>
# "myfiler:/export/home" \}} would make sure that \verb!myfiler!'s
# \verb!/export/home! share is mounted as \verb!/net/home!.
#
# To remove an automount entry:
#
# {\tt automount::mount \{ \emph{name}:
#      from => "\emph{nfs path}",
#      ensure => absent
# \}}
#
# If you have additional mount options (such as you would give to
# \verb!mount(1)!'s \verb!-o! switch), give them in an array as the
# options parameter. For example:
#
# {\tt automount::mount \{ 'home':
#      from => 'myfiler:/export/home',
#      options => ['nolocks','nordirplus'],
# \}}
#
# The options given in the options parameter may be inside multiple
# levels of arrays; this is so that you can create layers of
# abstraction above this define. The set of available options varies
# from platform to platform, and the behavior when an unknown option
# is supplied may also vary.
#
#
# \dinkus

define automount::mount($from, $under='', $ensure='present', $options=[]) {
    include automount

    case $::osfamily {
        'redhat': {
            automount::mount::redhat { $name:
                from => $from,
                under => $under,
                ensure => $ensure,
                options => $options,
            }
        }
        'darwin': {
            automount::mount::darwin { $name:
                from => $from,
                under => $under,
                ensure => $ensure,
                options => $options,
            }
        }
        default: { unimplemented() }
    }
}
