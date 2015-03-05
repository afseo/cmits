module Test_postgresql =
    let empty = Postgresql.empty
    let entry = Postgresql.entry
    let lns = Postgresql.lns

    test empty get "\n" = {}
    test entry get "\n" = *
    test lns get "
# This is a comment
setting = value
" = (
  { }
  { "#comment" = "This is a comment" }
  { "setting" = "value" }
)

    test lns get "
setting = value # same-line comment
" = (
  { }
  { "setting" = "value"
    { "#comment" = "same-line comment" }
  }
)

    (* i guess IniFile isn't so smart as to remove and re-add quotes *)
    test lns get "
setting = \"value with spaces\"
" = (
  { }
  { "setting" = "\"value with spaces\"" }
)

    (* nor to ignore comment characters inside quotes *)
    test lns get "
setting = \"value with # bla\" # psyche out
" = (
  { }
  { "setting" = "\"value with"
    { "#comment" = "bla\" # psyche out" }
  }
)

    test lns get "

#------------------------------------------------------------------------------
# CLIENT CONNECTION DEFAULTS
#------------------------------------------------------------------------------

# These settings are initialized by initdb, but they can be changed.
lc_messages = 'en_US.UTF-8'                     # locale for system error message
                                        # strings
lc_monetary = 'en_US.UTF-8'                     # locale for monetary formatting
lc_numeric = 'en_US.UTF-8'                      # locale for number formatting
lc_time = 'en_US.UTF-8'                         # locale for time formatting

# default configuration for text search
default_text_search_config = 'pg_catalog.english'

# - Other Defaults -

#dynamic_library_path = '$libdir'
#local_preload_libraries = ''
" = (
  {  }
  {  }
  { "#comment" = "------------------------------------------------------------------------------" }
  { "#comment" = "CLIENT CONNECTION DEFAULTS" }
  { "#comment" = "------------------------------------------------------------------------------" }
  {  }
  { "#comment" = "These settings are initialized by initdb, but they can be changed." }
  { "lc_messages" = "'en_US.UTF-8'"
    { "#comment" = "locale for system error message" }
  }
  { "#comment" = "strings" }
  { "lc_monetary" = "'en_US.UTF-8'"
    { "#comment" = "locale for monetary formatting" }
  }
  { "lc_numeric" = "'en_US.UTF-8'"
    { "#comment" = "locale for number formatting" }
  }
  { "lc_time" = "'en_US.UTF-8'"
    { "#comment" = "locale for time formatting" }
  }
  {  }
  { "#comment" = "default configuration for text search" }
  { "default_text_search_config" = "'pg_catalog.english'" }
  {  }
  { "#comment" = "- Other Defaults -" }
  {  }
  { "#comment" = "dynamic_library_path = '$libdir'" }
  { "#comment" = "local_preload_libraries = ''" }
)

