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
# \subsection{Ensure validity of password file}
class user::valid {
# \implements{unixsrg}{GEN000300,GEN000320,GEN000380} Make sure that user ids
# and user names are unique across all accounts, and that every user's primary
# group is one defined in the group file.
#
# \implements{unixsrg}{GEN001440,GEN001460} Make sure that all users have a
# home, and that each user's home exists.
    exec { "pwck -r":
        path => "/usr/sbin",
        command => "pwck -r",
        logoutput => on_failure,
        loglevel => err,
        unless => "pwck -r",
    }

# Resolve some complaints about home directories.
    if $::osfamily == 'RedHat' and $::operatingsystemrelease =~ /^6\..*/ {
        $users_array = split($::local_usernames, ' ')
        $has_pulse = inline_template('<%= @users_array.member? "pulse"-%>')
        $has_avahi = inline_template('<%= @users_array.member? "avahi-autoipd"-%>')
        if $has_avahi == 'true' {
            file { '/var/lib/avahi-autoipd':
                ensure => directory,
                owner => 'avahi-autoipd', group => 'root', mode => 0755,
            }
        }
        if $has_pulse == 'true' {
            file { '/var/run/pulse':
                ensure => directory,
                owner => 'pulse', group => 'root', mode => 0755,
            }
        }
    }
}
# About the \verb!unless! above: Jacob Helwig said on the \verb!puppet-users!
# mailing list, 7 Jun 2011,
# \begin{quote}
# By doing the "unless => 'pwck -r'", the resource won't even show up as having
# been run if 'pwck -r' returns 0.  Having to run the command twice is a hack,
# but it's the best I can think of at the moment.
# \end{quote}
# See also \url{http://projects.puppetlabs.com/issues/7877}.

