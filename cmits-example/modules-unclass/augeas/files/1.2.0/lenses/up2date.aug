module Up2date =
    autoload xfm

    (* funky syntax: this matches one or more of a-z, A-Z, [ or ]. *)
    let akey = /[]a-zA-Z[]+/
    let avalue = /[^ \t\n]*([ \t]+[^ \t\n]+)*/
    let setting = Build.key_value_line akey (del "=" "=") (store avalue)
    let lns = ( Util.empty | Util.comment | setting ) *

    let xfm = transform lns (incl "/etc/sysconfig/rhn/up2date")
