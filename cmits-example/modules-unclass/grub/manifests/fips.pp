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
# \subsection{Enable FIPS-compliant kernel mode}
#
# See \S\ref{class_fips}.

class grub::fips {
    $g = "/boot/grub/grub.conf"
    exec { "fipsify_kernel_cmdlines":
        path => "/bin:/sbin",
        onlyif => "grep '^[[:space:]]*kernel' $g | \
                   grep -v fips=1 >&/dev/null",
        command => "sed -i.fips -e \
            '/^[[:space:]]*kernel/s/\$/ fips=1/' $g",
        logoutput => true,
    }
# Warning: this probably won't work right with EFI. See \url{https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/chap-Federal_Standards_and_Regulations.html}.
    exec { "bootify_kernel_cmdlines":
        path => '/bin:/sbin',
        onlyif => "grep '^[[:space:]]*kernel' $g | \
                   grep -v boot=${::boot_filesystem_device} \
                       >&/dev/null",
        command => "sed -i.fips2 -e \
            '/^[[:space:]]*kernel/s!\$! boot=${::boot_filesystem_device}!' $g",
        logoutput => true,
    }
}
