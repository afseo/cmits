(* abrt.conf is mostly like Puppet configuration, i.e., an ini file
   with # for comments; but it can have numeric keys *)
module Abrt =
 autoload xfm
 (* allow numeric keys; IniFile.entry_re does not have 0-9 in the first [] *)
 let entry_re = /[A-Za-z0-9][A-Za-z0-9\._-]+/
 let entry = IniFile.indented_entry entry_re Puppet.sep Puppet.comment
 let record = IniFile.record Puppet.title entry
 let lns = IniFile.lns record Puppet.comment
 let xfm = transform lns (incl "/etc/abrt/abrt.conf")
