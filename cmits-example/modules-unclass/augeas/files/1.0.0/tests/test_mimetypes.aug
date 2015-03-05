module Test_mimetypes =
    let mime_type = Mimetypes.mime_type
    let rules = Mimetypes.rules
    let lns = Mimetypes.lns

    test [ mime_type ] get "text/plain" = { = "text/plain" }
    test [ mime_type ] get "application/beep+xml" = { = "application/beep+xml" }
    test [ mime_type ] get "application/vnd.fdf" = { = "application/vnd.fdf" }
    (* who in their right mind made this mime type?! ... oh wait, they weren't,
       it's microsoft *)
    test [ mime_type ] get
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        { = "application/vnd.openxmlformats-officedocument.wordprocessingml.document" }
    test rules get "text/plain txt\n" =
        { "rules" = "text/plain"
          { "rule" = "txt" } }
    test rules get "application/vnd.openxmlformats-officedocument.wordprocessingml.document docx\n" =
        { "rules" = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          { "rule" = "docx" } }
    test rules get "video/mpeg                      mpeg mpg mpe\n" =
        { "rules" = "video/mpeg"
          { "rule" = "mpeg" }
          { "rule" = "mpg" }
          { "rule" = "mpe" } }
    test lns get "
# This is a comment. I love comments.

# This file controls what Internet media types are sent to the client for
# given file extension(s).  Sending the correct media type to the client
# is important so they know how to handle the content of the file.
# Extra types can either be added here or by using an AddType directive
# in your config files. For more information about Internet media types,
# please read RFC 2045, 2046, 2047, 2048, and 2077.  The Internet media type
# registry is at <http://www.iana.org/assignments/media-types/>.

# MIME type                     Extension
application/EDI-Consent
application/andrew-inset        ez
application/mac-binhex40        hqx
application/mac-compactpro      cpt
application/octet-stream        bin dms lha lzh exe class so dll img iso
application/ogg                 ogg

" = (
  {  }
  { "#comment" = "This is a comment. I love comments." }
  {  }
  { "#comment" = "This file controls what Internet media types are sent to the client for" }
  { "#comment" = "given file extension(s).  Sending the correct media type to the client" }
  { "#comment" = "is important so they know how to handle the content of the file." }
  { "#comment" = "Extra types can either be added here or by using an AddType directive" }
  { "#comment" = "in your config files. For more information about Internet media types," }
  { "#comment" = "please read RFC 2045, 2046, 2047, 2048, and 2077.  The Internet media type" }
  { "#comment" = "registry is at <http://www.iana.org/assignments/media-types/>." }
  {  }
  { "#comment" = "MIME type                     Extension" }
  { "rules" = "application/EDI-Consent" }
  { "rules" = "application/andrew-inset"
    { "rule" = "ez" }
  }
  { "rules" = "application/mac-binhex40"
    { "rule" = "hqx" }
  }
  { "rules" = "application/mac-compactpro"
    { "rule" = "cpt" }
  }
  { "rules" = "application/octet-stream"
    { "rule" = "bin" }
    { "rule" = "dms" }
    { "rule" = "lha" }
    { "rule" = "lzh" }
    { "rule" = "exe" }
    { "rule" = "class" }
    { "rule" = "so" }
    { "rule" = "dll" }
    { "rule" = "img" }
    { "rule" = "iso" }
  }
  { "rules" = "application/ogg"
    { "rule" = "ogg" }
  }
  {  }
)

    test lns put "" after
             set "/rules[.=\"application/mac-binhex40\"]"
                 "application/mac-binhex40" ;
             set "/rules[.=\"application/mac-binhex40\"]/rule"
                 "hqx"
        = "application/mac-binhex40 hqx\n"
