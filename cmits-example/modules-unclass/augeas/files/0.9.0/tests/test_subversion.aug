module Test_subversion =
    let lns = Subversion.lns
    test lns get "
[global]
foo = bar
" = (
  { }
  { "global"
    { "foo" = "bar" }
  }
)

