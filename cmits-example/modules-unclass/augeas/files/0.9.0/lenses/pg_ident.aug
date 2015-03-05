module Pg_Ident =
    autoload xfm
    let identifier = store /[a-z_][^ \t\n#]*/
    let record = [ seq "entries" .
                   [ label "map" . identifier ] .
                   Util.del_ws_spc .
                   [ label "os_user" . identifier ] .
                   Util.del_ws_spc .
                   [ label "db_user" . identifier ] .
                   Util.eol
                 ]
    let empty = Util.empty
    let comment = Util.comment
    let line = empty | comment | record
    let lns = line *
    let xfm = transform lns (incl "/var/lib/pgsql/data/pg_ident.conf")
