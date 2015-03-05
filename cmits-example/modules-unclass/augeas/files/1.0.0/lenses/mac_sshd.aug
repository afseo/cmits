(* Tell Augeas to use the sshd lens on Macs, where SSH configuration is
   directly in /etc, not in /etc/ssh. *)
module Mac_sshd =
    let lns = Sshd.lns
    let xfm = transform lns (incl "/etc/sshd_config")
