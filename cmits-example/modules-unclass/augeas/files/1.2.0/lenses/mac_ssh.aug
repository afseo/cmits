(* Tell Augeas to use the ssh lens on Macs, where SSH configuration is directly
   in /etc, not in /etc/ssh. *)
module Mac_ssh =
    let lns = Ssh.lns
    let xfm = transform lns (incl "/etc/ssh_config")
