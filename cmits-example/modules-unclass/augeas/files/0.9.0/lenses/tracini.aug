(* This began as a copy of <Puppet> *)

module Tracini =
  autoload xfm

(************************************************************************
 * INI File settings
 *
 * puppet.conf only supports "# as commentary and "=" as separator
 *************************************************************************)
let comment    = IniFile.comment "#" "#"
let sep        = IniFile.sep "=" "="


(************************************************************************
 *                        ENTRY
 * puppet.conf uses standard INI File entries
 *************************************************************************)
(* began with IniFile.entry_re *)
(* added star as a valid non-first char in entry keys *)
(* allowed single-character entry keys *)
let entry_re           = ( /[A-Za-z][A-Za-z0-9*\._-]*/ )
let entry   = IniFile.indented_entry entry_re sep comment


(************************************************************************
 *                        RECORD
 * puppet.conf uses standard INI File records
 *************************************************************************)
let title   = IniFile.indented_title IniFile.record_re
let record  = IniFile.record title entry


(************************************************************************
 *                        LENS & FILTER
 * puppet.conf uses standard INI File records
 *************************************************************************)
let lns     = IniFile.lns record comment

let filter = (incl "/var/www/tracs/*/conf/trac.ini")

let xfm = transform lns filter
