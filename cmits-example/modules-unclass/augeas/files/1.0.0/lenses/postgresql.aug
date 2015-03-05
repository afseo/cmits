module Postgresql =
    autoload xfm

    let comment = Inifile.comment "#" "#"
    let empty = Inifile.empty
    let eq = del /[ \t]*=/ " ="
    let entry = IniFile.entry IniFile.entry_re eq comment

    let lns = ( entry | empty ) *

    let xfm = transform lns (incl "/var/lib/pgsql/*/postgresql.conf")
