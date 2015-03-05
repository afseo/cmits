module Automaster =
    autoload xfm
    
    let eol = Util.eol
    let comment = Util.comment
    let empty = Util.empty

    let mount_point = store /\/[^# \t\n]+/
    let include = [ label "include" . 
                    del /\+[ \t]*/ "+" .
                    store /[^# \t\n]+/ .
                    eol ]
    let options = [ label "options" . store /-[^ \t\n]+/ ]
    let map_param = 
        let    name = [ label "name" . store /[^: \t\n]+/ ]
        in let type = [ label "type" . store /[a-z]+/ ]
        in let format = [ label "format" . store /[a-z]+/ ]
        in let options = [ label "options" . store /[^ \t\n]+/ ]
        in let prelude = ( type .
                           ( del "," "," . format ) ? .
                           del ":" ":" )
        in ( prelude ? .
             name .
             ( Util.del_ws_spc . options ) ? )
    let map_record = [ label "map" .
                       mount_point . Util.del_ws_spc .
                       map_param .
                       eol ]

    let lns = ( map_record |
                include |
                comment |
                empty ) *

    let relevant = (incl "/etc/auto.master") .
                   Util.stdexcl
    let xfm = transform lns relevant

