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
# \subsection{Disable SCTP}
#
# \implements{unixsrg}{GEN007020} Disable the Stream Control Transmission
# Protocol (SCTP) ``unless required.'' We do not need it.
class network::no_sctp {
    package {
        "lksctp-tools": ensure => absent;
        "lksctp-tools-debuginfo": ensure => absent;
        "lksctp-tools-devel": ensure => absent;
        "lksctp-tools-doc": ensure => absent;
    }
    kernel_module { "sctp": ensure => absent }
# ``Unprivileged local processes may be able to cause the system to dynamically
# load a protocol handler by opening a socket using the protocol.'' (SRG
# discussion) Prevent this by removing related kernel module files.
    file {
        "/lib/modules/$kernelrelease/kernel/net/sctp":
            ensure => absent,
            recurse => true,
            recurselimit => 1,
            force => true,
    }
}
