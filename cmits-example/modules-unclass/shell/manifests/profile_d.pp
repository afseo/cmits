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
class shell::profile_d {
# Make sure the \verb!profile.d! directory exists.
    require shell::global_init_files
    exec { "use profile.d":
        path => ['/bin', '/usr/bin'],
        command => "sed -i .before_profile_d -e '\$a\\
for i in /etc/profile.d/*.sh; do\\
\\    if [ -r \"\$i\" ]; then\\
\\        . \"\$i\"\\
\\    fi\\
done\\
' /etc/profile",
        unless => "grep -- 'if \\[ -r \"\\\$i' /etc/profile",
    }
}
