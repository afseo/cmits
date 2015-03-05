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
# \subsubsection{Under RHEL5}

class dod_login_warnings::gdm::rhel5 {
    include zenity
    include ::gdm::rhel5

    # This one is for zenity to show. zenity can word-wrap.
    file { "/etc/issue_paragraphs":
        owner => root, group => 0, mode => 0644,
        source => "puppet:///modules/\
dod_login_warnings/paragraphs",
    }

    exec { 'show_gdm_login_warning':
        command => "sed -i -e '/^exit 0$/i \
zenity --error --text \"`cat /etc/issue_paragraphs`\"
' /etc/gdm/Init/Default",
        unless => "grep 'zenity.*error.*issue.*' \
                   /etc/gdm/Init/Default",
        notify => Exec['restart_gdm'],
        require => Class['gdm::logo'],
    }
}
