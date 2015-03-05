module Test_pg_ident =
    let empty = Pg_ident.empty
    let record = Pg_ident.record
    let lns = Pg_ident.lns

    test empty get "\n" = {}
    test record get "\n" = *
    test lns get "
# This is a comment
a b c
" = (
  { }
  { "#comment" = "This is a comment" }
  { "1"
    { "map" = "a" }
    { "os_user" = "b" }
    { "db_user" = "c" }
  }
)

