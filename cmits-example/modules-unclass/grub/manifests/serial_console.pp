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
# \subsection{Enable serial console}
#
# See \S\ref{class_serial_console}.

class grub::serial_console($speed=9600) {

# First, make all the kernels treat the serial port as the console.
    $g = "/boot/grub/grub.conf"
    exec { "serial_console_ify_kernel_cmdlines":
        path => "/bin:/sbin",
        onlyif => "grep '^[[:space:]]*kernel' $g | \
                   grep -v console=ttyS0,${speed}n8 >&/dev/null",
        command => "sed -i.serial_console_kernels -e \
            '/[[:space:]]*kernel/s/\$/ console=tty console=ttyS0,${speed}n8 /' $g",
        logoutput => true,
    }

# Then, make grub itself treat the serial port as the console.
#
# Regarding the terminal command: "When both the serial port and the attached
# monitor and keyboard are configured they will both ask for a key to be
# pressed until the timeout expires. If a key is pressed then the boot menu is
# displayed to that device.  Disconcertingly, the other device sees nothing."

    exec { "serial_console_ify_grub":
        path => "/bin:/sbin",
        unless => "grep ^serial $g",
        command => "sed -i.serial_console_grub -e \
            '/[[:space:]]*default/i \\\n\
serial --unit=0 --speed=${speed} \
 --word=8 --parity=no --stop=1\\\n\
terminal --timeout=10 serial console\n\
' $g",
        logoutput => true,
    }
}
