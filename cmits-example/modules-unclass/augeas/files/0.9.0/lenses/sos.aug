module Sos =
 autoload xfm
 let lns = Puppet.lns
 let xfm = transform lns (incl "/etc/sos.conf")
