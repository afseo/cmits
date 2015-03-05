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
# \subsection{Random number generator}
#
# When in FIPS-compliant mode, OpenSSL uses \verb!/dev/random! for its
# randomness needs. This can be much slower without any decent sources of
# randomness, such as network packets, console keystrokes, etc., which a
# virtual machine may lack. The \verb!virtio-rng! module uses randomness from
# the host system in the virtual machine, improving the performance of
# \verb!/dev/random!.

class kvm::guest_random {
    if $virtual == "kvm" {
# See \cite{rhel6-deployment}, \S 22.6, ``Persistent Module Loading.''
        file { "/etc/sysconfig/modules/virtio-rng.modules":
            owner => root, group => 0, mode => 0755,
            content => "#!/bin/sh\nmodprobe virtio-rng\n",
        }
    }
}
