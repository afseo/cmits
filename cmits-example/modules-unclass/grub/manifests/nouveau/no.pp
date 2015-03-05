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
# \subsubsection{Disable Nouveau driver in initrd}
# This action is originally documented in the README for the NVIDIA driver.

class grub::nouveau::no {
    $g = "/boot/grub/grub.conf"
    exec { "disable_nouveau_kernel_cmdlines":
        path => "/bin:/sbin",
        onlyif => "grep '^[[:space:]]*kernel' $g | \
                   grep -v nouveau >&/dev/null",
        command => "sed -i.disable_nouveau -e \
                    '/[[:space:]]*kernel/s/\$/ rdblacklist=nouveau /' $g",
        logoutput => true,
    }
}
