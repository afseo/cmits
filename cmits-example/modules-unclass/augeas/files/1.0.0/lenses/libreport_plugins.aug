module Libreport_plugins =

autoload xfm

let entry = Build.key_value_line /[A-Za-z]+/ Sep.equal (store /[^\n]*[^ \t\n]+/)

let lns = ( Util.comment | Util.empty | entry ) *

let filter = (incl "/etc/libreport/plugins/*.conf") . Util.stdexcl
let xfm = transform lns filter
