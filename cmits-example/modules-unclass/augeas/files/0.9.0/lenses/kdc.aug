module Kdc =

autoload xfm

let comment = Krb5.comment
let empty = Krb5.empty

let simple_section = Krb5.simple_section
let kdcdefaults = 
  simple_section "kdcdefaults" /kdc_ports|kdc_tcp_ports/

let realm_re = Krb5.realm_re
let entry = Krb5.entry
let eq = Krb5.eq
(* the Krb5.eq_openbr didn't have a newline at the end *)
let eq_openbr = del /[ \t]*=[ \t\n]*\{([ \t]*\n)*/ " = {\n\n"
let closebr = Krb5.closebr
let indent = Krb5.indent
let eol = Krb5.eol
let record = Krb5.record
let realms_enctypes = [ indent . key "supported_enctypes" . eq .
        [ label "type" . store /[^ \t\n#]+/ . Util.del_ws_spc ] * .
        [ label "type" . store /[^ \t\n#]+/ . eol ] ]

let realms =
  let simple_option = /master_key_type|acl_file|dict_file|admin_keytab/ in
  let list_option = /supported_enctypes/ in
  let soption = entry simple_option eq comment in
  let realm = [ indent . label "realm" . store realm_re .
                  eq_openbr . eol . (soption|realms_enctypes)* . closebr . eol ] in
    record "realms" (realm|comment)


let lns = (comment|empty)* . 
  (kdcdefaults|realms)*

let xfm = transform lns (incl "/var/kerberos/krb5kdc/kdc.conf")
