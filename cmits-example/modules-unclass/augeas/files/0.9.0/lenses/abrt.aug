(* ABRT 2 configuration is like an ini file with no sections *)
module Abrt =
    autoload xfm

    let comment = Inifile.comment "#" "#"
    let empty = Inifile.empty
    let eq = del /[ \t]*=/ " ="
    let entry = IniFile.entry IniFile.entry_re eq comment

    let lns = ( entry | empty ) *

    let xfm = transform lns (incl "/etc/abrt/*.conf" . incl "/etc/abrt/plugins/*.conf")
