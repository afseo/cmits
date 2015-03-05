(* Upstart init configuration files such as found in /etc/init *)

module Upstartinit =
    autoload xfm

    let eol = Util.eol
    let rest_of_line = /[^ \t\n]+([ \t]+[^ \t\n]+)*/
    let whole_line_maybe_indented = /[ \t]*[^ \t\n]+([ \t]+[^ \t\n]+)*/
    let no_params = [ key "task" . eol ]

    let param_is_rest_of_line (thekey:regexp) =
        Build.key_value_line thekey 
                             Util.del_ws_spc
                             (store rest_of_line)

    let respawn = [ key "respawn" . 
          (Util.del_ws_spc . store rest_of_line)? . eol ]


    let one_params = param_is_rest_of_line
          ( "start"
          | "stop"
          | "env"
          | "export"
          | "normal exit"
          | "instance"
          | "description"
          | "author"
          | "version"
          | "emits"
          | "console"
          | "umask"
          | "nice"
          | "oom"
          | "chroot"
          | "chdir"
          | "limit"
          | "unlimited"
          | "kill timeout"
          | "expect"
          | "usage"
          )

    (* exec and script are valid both at the top level and as a parameter of a
    lifecycle keyword *)
    let exec = param_is_rest_of_line "exec"

    let script_line = [ seq "line" . 
                        store ( whole_line_maybe_indented - "end script" ) .
                        eol ] |
                      [ seq "line" . eol]
    let end_script = del "end script\n" "end script\n"
    let script = [ key "script" . eol . script_line * . end_script ]

    let lifecycle = [ key /(pre|post)-(start|stop)/ .  Util.del_ws_spc . ( exec | script ) ]

    let lns = ( Util.empty
              | Util.comment
              | script
              | exec
              | lifecycle
              | no_params
              | one_params
              | respawn
              ) *

    let relevant = (incl "/etc/init/*.conf") . Util.stdexcl
    let xfm = transform lns relevant

