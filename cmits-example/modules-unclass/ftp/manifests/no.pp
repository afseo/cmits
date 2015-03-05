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
# \subsection{Disable FTP}

class ftp::no {

# \implements{unixsrg}{GEN004800,GEN004820,GEN004840}%
# Remove FTP server software wherever possible.
    package { "vsftpd": ensure => absent }

# Remove the ftp user so pwck will be happy. Since it's a system uid, chances
# that it will be reused for a different user are lower; so if ftp happened to
# own any files they will likely remain secure.
    user { "ftp": ensure => absent }

}

# \notapplicable{unixsrg}{GEN004880,GEN004900,GEN004920,GEN004930,GEN004940,GEN004950}%
# Where FTP is disabled, the \verb!ftpusers! file likely does not exist, but
# that isn't a problem.
#
# \notapplicable{rhel5stig}{GEN004980}%
# Where FTP is disabled, the FTP daemon cannot be ``configured for logging or
# verbose mode.''
#
# \notapplicable{unixsrg}{GEN005000,GEN005020,GEN005040}%
# Since we have no FTP servers, we do no anonymous FTP.

