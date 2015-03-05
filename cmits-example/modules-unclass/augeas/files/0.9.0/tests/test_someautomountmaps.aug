module Test_someautomountmaps =
    let script_content = Someautomountmaps.script_content
    let comment = Someautomountmaps.comment
    let automount_key = Someautomountmaps.automount_key
    let entry = Someautomountmaps.entry
    let lns = Someautomountmaps.lns

    test script_content get
        "#!/bin/bash\nfoo\n    bar\n\tbaz\nbletch\n#comment\n"
        = { "script_content" =
        "#!/bin/bash\nfoo\n    bar\n\tbaz\nbletch\n#comment\n" }
    test comment get "# bla\n" = { "#comment" = "bla" }
    test entry get "\n" = *
    test entry get "foo -fstype=nfs,ro filer:/vol/foo\n" =
        { "entry" = "foo"
            { "options" = "fstype=nfs,ro" }
            { "location" = "filer:/vol/foo" }
        }
    test entry get "foo filer:/vol/foo\n" =
        { "entry" = "foo"
            { "options" }
            { "location" = "filer:/vol/foo" }
        }
    test lns get "foo filer:/vol/foo\n" =
        { "entry" = "foo"
            { "options" }
            { "location" = "filer:/vol/foo" }
        }
    test lns get "\n" = { }
    test lns get "# first line comment but not a hashbang!
foo -fstype=nfs,ro filer:/vol/foo
bar filer2:/vol/bar
# another comment
baz asdfsf
" = (
  { "#comment" = "first line comment but not a hashbang!" }
  { "entry" = "foo"
    { "options" = "fstype=nfs,ro" }
    { "location" = "filer:/vol/foo" }
  }
  { "entry" = "bar"
    { "options" }
    { "location" = "filer2:/vol/bar" }
  }
  { "#comment" = "another comment" }
  { "entry" = "baz"
    { "options" }
    { "location" = "asdfsf" }
  }
)

    test lns put "foo filer:/vol/foo\n" after set "/entry[.='foo']/options" "proto=tcp" = "foo -proto=tcp filer:/vol/foo\n"
