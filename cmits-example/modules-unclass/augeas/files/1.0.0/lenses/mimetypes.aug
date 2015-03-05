module Mimetypes =
    autoload xfm

    (* RFC 2045, Page 11. Closing square bracket moved out of sequence to
       satisfy regex syntax. token_first excludes pound signs so as not to
       overlap with the syntax for comments. *)
    let token =
           let first = /[^]#()<>@,;:\\"\/[?= \t\n]/
        in let rest  =  /[^]()<>@,;:\\"\/[?= \t\n]*/
        in first . rest
    (* We can't use the mime type as a key, because it has a slash in it *)
    let mime_type = store (token . "/" . token)
    (* This will split up rules wrong if you use spaces within a rule, e.g.
    "ascii(34, 3)" or "string(34,'foo bar')". But all the rules I've ever seen
    were just filename extensions, so this won't fail until people forget what
    it is and have to dig to find it. *)
    let a_rule = [ Util.del_ws_spc . label "rule" . store /[^ \t\n]+/ ]
    let rules = [ label "rules" . mime_type . (a_rule *) . Util.eol ]
    let line = ( rules | Util.comment | Util.empty )
    let lns = ( line * )

    let xfm = transform lns (incl "/etc/mime.types")
