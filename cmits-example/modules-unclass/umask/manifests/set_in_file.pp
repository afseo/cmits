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
# \subsection{Set umasks in shell startup files}
#
# This defined resource type can make sure a umask is set properly in
# a file. It works if the syntax of the umask command is, e.g.,
# \verb!umask 077!, and if lines added to the end of the file will
# have the proper effect. You have to ensure the file is present
# yourself.
#
# \begin{verbatim}
# umask::set_in_file { '/etc/bashrc': umask => 077 }
# \end{verbatim}
# \dinkus

define umask::set_in_file($umask) {
    $sed_i_umask = $::osfamily ? {
        'RedHat' => 'sed -i.before_umask',
        'Darwin' => 'sed -i .before_umask',
        default  => unimplemented(),
    }
    exec { "add umask ${umask} to ${name}":
        command => "echo 'umask ${umask}' >> ${name}",
        unless => "grep '^[[:space:]]*umask' ${name}",
        path => ['/bin', '/usr/bin'],
        require => File[$name],
    }
    exec { "change umask to ${umask} in ${name}":
        command => "${sed_i_umask} -e \
        's/\\(^[[:space:]]*umask\\>\\).*/\\1 ${umask}/' \
        ${name}",
        onlyif => "grep '^[[:space:]]*umask' ${name} | \
        grep -v 'umask ${umask}\$'",
        path => ['/bin', '/usr/bin'],
    }
}
