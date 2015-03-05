module Test_abrt =
    let lns = Abrt.lns
    test lns get "
# Configuration file for CCpp hook

# If you also want to dump file named \"core\"
# in crashed process' current dir, set to \"yes\"
MakeCompatCore = yes

# Do you want a copy of crashed binary be saved?
# (useful, for example, when _deleted binary_ segfaults)
SaveBinaryImage = no

# Used for debugging the hook
#VerboseLog = 2

# Specify where you want to store debuginfos (default: /var/cache/abrt-di)
#
#DebuginfoLocation = /var/cache/abrt-di
" = (
  {  }
  { "#comment" = "Configuration file for CCpp hook" }
  {  }
  { "#comment" = "If you also want to dump file named \"core\"" }
  { "#comment" = "in crashed process' current dir, set to \"yes\"" }
  { "MakeCompatCore" = "yes" }
  {  }
  { "#comment" = "Do you want a copy of crashed binary be saved?" }
  { "#comment" = "(useful, for example, when _deleted binary_ segfaults)" }
  { "SaveBinaryImage" = "no" }
  {  }
  { "#comment" = "Used for debugging the hook" }
  { "#comment" = "VerboseLog = 2" }
  {  }
  { "#comment" = "Specify where you want to store debuginfos (default: /var/cache/abrt-di)" }
  { "#comment" }
  { "#comment" = "DebuginfoLocation = /var/cache/abrt-di" }
)
