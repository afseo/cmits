(* it's just an ini file. sections ("titles") are required *)
module Gdm2conf =
    autoload xfm

    let comment = IniFile.comment "#" "#"
    let sep = IniFile.sep "=" "="
    let entry = IniFile.indented_entry IniFile.entry_re sep comment
    let title = IniFile.indented_title IniFile.record_re
    let record = IniFile.record title entry

    let lns = IniFile.lns record comment

    let relevant = ( incl "/etc/gdm/custom.conf" ) . 
                   ( incl "/etc/gdm/securitytokens.conf" )

    let xfm = transform lns relevant
