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
# \section{Serial port console support}
#
# This is the stuff necessary to make the system console go over the serial
# port instead of the video card and keyboard.
#
# I've got this Cyclades ACS48 48-port \emph{terminal server}, meaning a
# solid-state, special-purpose device with 48 serial ports which hooks up to a
# master serial port and/or a network, and serves access to the serial ports
# via these latter two means. Consoles of the switch and RAID shelves are
# already available via this terminal server; consoles of Linux servers may as
# well be available by the same means. 
#
# There are important security implications: access to the terminal server is
# mostly equivalent to physical access to the hardware in question, just like a
# KVM switch. The Network Infrastructure STIG may or may not effectively
# relegate the terminal server device to a separate management network.
#
# There are roughly three places to set this: grub, the kernel, and the
# inittab. Both the grub setting and the kernel setting happen in grub's
# menu.lst file; see \S\ref{class_grub::serial_console}. The inittab would
# usually be set to run a getty on the serial port, so that people can log in
# by that means. Under RHEL6, the default configuration appears to figure out
# whether the kernel's console is a serial port, and if so, start a getty on
# it. So we needn't worry about the getty part under RHEL6.
#
# Source:
# \url{http://tldp.org/HOWTO/Remote-Serial-Console-HOWTO/configure-boot-loader-grub.html}.
#

class serial_console($speed=9600) {
    class { 'grub::serial_console':
        speed => $speed,
    }
# There may be some changes necessary to the /etc/securetty file. If so they
# have not happened yet. See \S\ref{class_root::login}.
}
