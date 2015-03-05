(* based on the group module for Augeas by Free Ekanayaka <free@64studio.com>

 Reference: man 5 gshadow

*)

module Gshadow =

   autoload xfm

(************************************************************************
 *                           USEFUL PRIMITIVES
 *************************************************************************)

let eol        = Util.eol
let comment    = Util.comment
let empty      = Util.empty

let colon      = Sep.colon
let comma      = Sep.comma

let sto_to_spc = store Rx.space_in

let word    = Rx.word
let password = /[A-Za-z0-9_.!*\/$-]*/
let integer = Rx.integer

(************************************************************************
 *                               ENTRIES
 *************************************************************************)

let user      = [ label "user" . store word ]
let user_list = Build.opt_list user comma
let params    = [ label "password" . store password  . colon ]
                . [ label "admins" . user_list? . colon ]
                . [ label "members" . user_list? ]
let entry     = Build.key_value_line word colon params

(************************************************************************
 *                                LENS
 *************************************************************************)

let lns        = (comment|empty|entry) *

let filter
               = incl "/etc/gshadow"
               . Util.stdexcl

let xfm        = transform lns filter
