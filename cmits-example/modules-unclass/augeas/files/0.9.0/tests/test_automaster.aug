module Test_automaster =
    let map_param = Automaster.map_param
    let map_record = Automaster.map_record
    let lns = Automaster.lns

    test map_param get "file:/bla/blu" = 
        ( { "type" = "file" } { "name" = "/bla/blu" } )
    test map_param get "yp,hesiod:/bla/blu" = 
        ( { "type" = "yp" } 
          { "format" = "hesiod" }
          { "name" = "/bla/blu" } )
    test map_param get "bla" = { "name" = "bla" }
    test map_record get "/net /etc/auto.net\n" =
        { "map" = "/net"
            { "name" = "/etc/auto.net" } }

    test lns get "# c\n+auto.master\n/net /etc/auto.net\n\n" = (
        { "#comment" = "c" }
        { "include" = "auto.master" }
        { "map" = "/net"
            { "name" = "/etc/auto.net" }
        }
        {  } )

    test lns get "# c
+auto.master
# blank line


/net /etc/auto.net
/foo bla
" = (
  { "#comment" = "c" }
  { "include" = "auto.master" }
  { "#comment" = "blank line" }
  {  }
  {  }
  { "map" = "/net"
    { "name" = "/etc/auto.net" }
  }
  { "map" = "/foo"
    { "name" = "bla" }
  }
)

    test lns get "#
# Sample auto.master file
# This is an automounter map and it has the following format
# key [ -mount-options-separated-by-comma ] location
# For details of the format look at autofs(5).
#
/misc   /etc/auto.misc
#
# NOTE: mounts done from a hosts map will be mounted with the
#       \"nosuid\" and \"nodev\" options unless the \"suid\" and \"dev\"
#       options are explicitly given.
#
/net    -hosts
#
# Include central master map if it can be found using
# nsswitch sources.
#
# Note that if there are entries for /net or /misc (as
# above) in the included master map any keys that are the
# same will not be seen as the first read key seen takes
# precedence.
#
+auto.master
" = (
  {  }
  { "#comment" = "Sample auto.master file" }
  { "#comment" = "This is an automounter map and it has the following format" }
  { "#comment" = "key [ -mount-options-separated-by-comma ] location" }
  { "#comment" = "For details of the format look at autofs(5)." }
  {  }
  { "map" = "/misc"
    { "name" = "/etc/auto.misc" }
  }
  {  }
  { "#comment" = "NOTE: mounts done from a hosts map will be mounted with the" }
  { "#comment" = "\"nosuid\" and \"nodev\" options unless the \"suid\" and \"dev\"" }
  { "#comment" = "options are explicitly given." }
  {  }
  { "map" = "/net"
    { "name" = "-hosts" }
  }
  {  }
  { "#comment" = "Include central master map if it can be found using" }
  { "#comment" = "nsswitch sources." }
  {  }
  { "#comment" = "Note that if there are entries for /net or /misc (as" }
  { "#comment" = "above) in the included master map any keys that are the" }
  { "#comment" = "same will not be seen as the first read key seen takes" }
  { "#comment" = "precedence." }
  {  }
  { "include" = "auto.master" }
)
