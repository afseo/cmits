(* Parse pam_pkcs11 subject_mapping file 
   File is of the format:
   
   Certificate Distinguished Name, With Spaces and Commas, Bla Bla. -> username

   We're interested in preserving the one-to-one property, that is, that for a
   given username there is only one certificate. Because of this, and because
   the username is shorter and easier to type, we make the username the key
   instead of the certificate distinguished name.
*)

module Subject_mapping =
    autoload xfm
    (* can't have slashes in keys, that's another reason to make the username
       the key *)
    let username = key /[^>\/ \t\n-]+/
    let arrow = del /[ \t]*->[ \t]*/ " -> "
    let certdn = store /[^ \t\n]+([ \t]+[^ \t\n]+)*/
    let line = [ certdn . arrow . username . Util.eol ]

    let lns = line *

    let relevant = (incl "/etc/pam_pkcs11/subject_mapping")
    let xfm = transform lns relevant
