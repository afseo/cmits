module Test_libreport_plugins =

    let lns = Libreport_plugins.lns
    let entry = Libreport_plugins.entry

    test entry get "Foo=bar\n" = ( { "Foo" = "bar" } )
    test lns get "
# String parameters:

Subject=bla
# EmailFrom=
" = (
  { }
  { "#comment" = "String parameters:" }
  { }
  { "Subject" = "bla" }
  { "#comment" = "EmailFrom=" }
)