(* This lens does NOT parse all automount maps!
   It can deal with maps which are scripts (start with a hashbang), but not
   with multiple mounts nor with line continuations.
*)
module Someautomountmaps =
    autoload xfm
    
    let eol = Util.eol
    let script_content = [ label "script_content" . store /#!(.*[\n]*)*/ ]
    (* This is the same as Util.comment, except that it denies hashbangs.
       As a side effect it also denies comments that begin with a bang, like
       "# !blabalabl". Sloppy, but it works here now, and that's the point of
       this whole file. *)
    let indent = Util.indent
    let comment =
      [ indent . label "#comment" . del /#[ \t]*/ "# "
          . store /([^! \t\n].*[^ \t\n]|[^! \t\n])/ . eol ]
    (*                ^-- like so *)

    let automount_key = store /[^# \t\n]+/
    let options = [ label "options" .
                    ( del "-" "-" . 
                      store /[^ \t\n]+/ .
                      Util.del_ws_spc ) ? ]
    let location = [ label "location" . store /[^ \t\n]+/ ]
    let entry = [ label "entry" .
                   automount_key . Util.del_ws_spc .
                   options .
                   location . eol ]

    let lns = script_content | 
              ( comment | Util.empty | entry ) *

    let relevant = (incl "/etc/auto.*") .
                   (excl "/etc/auto.master") .
                   Util.stdexcl
    let xfm = transform lns relevant
