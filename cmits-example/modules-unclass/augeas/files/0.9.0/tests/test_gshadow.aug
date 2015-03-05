module Test_gshadow =
   let lns = Gshadow.lns
   let entry = Gshadow.entry
   test entry get "root:::\n" =
  { "root"
    { "password" = "" }
    { "admins" }
    { "members" }
  }

   test entry get "bin:::bin,daemon\n" =
  { "bin"
    { "password" = "" }
    { "admins" }
    { "members"
      { "user" = "bin" }
      { "user" = "daemon" }
    }
  }

   test entry get "dbus:!::\n" =
  { "dbus"
    { "password" = "!" }
    { "admins" }
    { "members" }
  }

   test entry get "ntp:!:foo,bar:baz,bletch\n" =
  { "ntp"
    { "password" = "!" }
    { "admins"
      { "user" = "foo" }
      { "user" = "bar" }
    }
    { "members"
      { "user" = "baz" }
      { "user" = "bletch" }
    }
  }

   test entry get "fooz:$5$GQPAI/174dH/Q$dQtmrhcGuolwm7DlKVFkeH.VCWbH1/XTYkXU83WkIO9::\n" =
  { "fooz"
    { "password" = "$5$GQPAI/174dH/Q$dQtmrhcGuolwm7DlKVFkeH.VCWbH1/XTYkXU83WkIO9" }
    { "admins" }
    { "members" }
  }



  

   test lns get 
"root:::
bin:::bin,daemon
dbus:!::
ntp:!:foo,bar:baz,bletch
fooz:$5$GQPAI/174dH/Q$dQtmrhcGuolwm7DlKVFkeH.VCWbH1/XTYkXU83WkIO9::
" =
  { "root"
    { "password" = "" }
    { "admins" }
    { "members" }
  }
  { "bin"
    { "password" = "" }
    { "admins" }
    { "members"
      { "user" = "bin" }
      { "user" = "daemon" }
    }
  }
  { "dbus"
    { "password" = "!" }
    { "admins" }
    { "members" }
  }
  { "ntp"
    { "password" = "!" }
    { "admins"
      { "user" = "foo" }
      { "user" = "bar" }
    }
    { "members"
      { "user" = "baz" }
      { "user" = "bletch" }
    }
  }
  { "fooz"
    { "password" = "$5$GQPAI/174dH/Q$dQtmrhcGuolwm7DlKVFkeH.VCWbH1/XTYkXU83WkIO9" }
    { "admins" }
    { "members" }
  }

