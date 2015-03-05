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
# \section{Mac launchd service definitions}
#
# A defined resource type that creates launchd service
# files. launchctl uses these to start and stop services; the Puppet
# service resource type can talk to launchctl. Just as the Puppet
# service type cannot create \verb!/etc/init.d! files under Linux, it
# also can't create \verb!/Library/LaunchDaemons! files on a Mac.
#
# Parameters: \verb!name! is the canonical name of the service. It's
# written in backward DNS, for example
# \verb!com.example.myservice!. This is the same name you'll need to
# tell the Puppet service resource type to start and stop the service
# once you've defined it using this type. \verb!description! is a
# vernacular description of the service. \verb!environment! is a hash
# with variable names as keys and values as values. \verb!arguments!
# is an array of arguments with which to run the program,
# \emph{starting with argument 0}, the program name.

define mac_launchd_file(
        $description,
        $environment,
        $arguments,
        $requires_network='true',
        ) {
    $ld = '/Library/LaunchDaemons'
    $plist = "${ld}/${name}.plist"
    file { $plist:
        ensure => present,
        owner => root, group => 0, mode => 0644,
    }
# Make the arguments always be an array, because in the property list
# file they should always be an array. See
# \url{http://projects.puppetlabs.com/issues/15813}. We assume here
# that if no arguments are to be given to the program to start, it's
# harmless to provide one argument which is an empty string.
   $arglength = inline_template("<%=@arguments.length%>")
   if $arglength == 1 {
        $array_args = [$arguments[0], ""]
    } else {
        $array_args = $arguments
    }

# From an old wiki page, \url{http://projects.puppetlabs.com/projects/1/wiki/Puppet_With_Launchd}, and \verb!launchd.plist(5)!.
    mac_plist_value {
        "${plist}:Label":
            value => $name;
        "${plist}:ServiceDescription":
            value => $description;
        "${plist}:EnvironmentVariables":
            value => $environment;
        "${plist}:ProgramArguments":
            value => $array_args;
    }
    case $requires_network {
        'true': {
            mac_plist_value {
                "${plist}:RunAtLoad":
                    value => false;
                "${plist}:KeepAlive":
                    value => {
                        'NetworkState' => true,
                        };
            }
        }
        default: {
            mac_plist_value {
                "${plist}:RunAtLoad":
                    value => true;
                "${plist}:KeepAlive":
                    value => true;
            }
        }
    }
}
