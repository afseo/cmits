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
# \subsection{Define a printer}
#
# This defined resource type adds or removes CUPS printers, and
# enables or disables them.
#
# It wraps the \verb!lpadmin(8)! command, \emph{q.v.}
#
# Caveats: Since we're running commands using the shell here, don't
# have any apostrophes in any parameters to this define. Printer names
# must not include the strings ``not accepting requests'' or
# ``disabled since.''
#
# Values you can use for the \verb!model! parameter can be listed
# using the CUPS command \verb!lpinfo -m!.

define cups::printer(
    $model,
    $options,
    $uri,
    $description,
    $location,
    $enable=true,
    $ensure=present,
    ) {

    $options_switches = inline_template("<%=
        options.collect {|k,v|
            \"-o '#{k}=#{v}'\"}.sort.join(' ') %>")

    case $ensure {
        'present': {
            exec { "create_printer_${name}":
                command => "lpadmin -p '${name}' \
                    -m '${model}' \
                    ${options_switches} \
                    -u allow:all \
                    -v '${uri}' \
                    -D '${description}' \
                    -L '${location}'",
                creates => "/etc/cups/ppd/${name}.ppd",
            }
            if $enable == true {
                exec { "accept_printer_${name}":
                    command => "cupsaccept '${name}'",
                    require => Exec["create_printer_${name}"],
                    onlyif => "lpstat -a '${name}' | \
                        grep 'not accepting requests'",
                }
                exec { "enable_printer_${name}":
                    command => "cupsenable '${name}'",
                    require => Exec["create_printer_${name}"],
                    onlyif => "lpstat -p '${name}' | \
                        grep 'disabled since'",
                }
            } else {
                exec { "reject_printer_${name}":
                    command => "cupsreject '${name}'",
                    require => Exec["create_printer_${name}"],
                    unless => "lpstat -a '${name}' | \
                        grep 'not accepting requests'",
                }
                exec { "disable_printer_${name}":
                    command => "cupsdisable '${name}'",
                    require => Exec["create_printer_${name}"],
                    unless => "lpstat -p '${name}' | \
                        grep 'disabled since'",
                }
            }
        }
        'absent': {
            exec { "remove_printer_${name}":
                command => "lpadmin -x '${name}'",
                onlyif => "lpstat -p '${name}'",
            }
        }
        default: {
            fail("ensure value must be present or absent")
        }
    }
}
