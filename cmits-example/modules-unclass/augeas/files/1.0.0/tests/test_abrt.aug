module Test_abrt =
    let lns = Abrt.lns
    test lns get "
[ Common ]
# With this option set to \"yes\",
# only crashes in signed packages will be analyzed.
# the list of public keys used to check the signature is
# in the file gpg_keys
#
OpenGPGCheck = yes

# Blacklisted packages
#
BlackList = nspluginwrapper, valgrind, strace, mono-core

# Process crashes in executables which do not belong to any package?
#
ProcessUnpackaged = no

# Blacklisted executable paths (shell patterns)
#
BlackListedPaths = /usr/share/doc/*, */example*, /usr/bin/nspluginviewer

# Which database plugin to use
#
Database = SQLite3

# Enable this if you want abrtd to auto-unpack crashdump tarballs which appear
# in this directory (for example, uploaded via ftp, scp etc).
# Note: you must ensure that whatever directory you specify here exists
# and is writable for abrtd. abrtd will not create it automatically.
#
#WatchCrashdumpArchiveDir = /var/spool/abrt-upload

# Max size for crash storage [MiB] or 0 for unlimited
#
MaxCrashReportsSize = 1000

# Vector of actions and reporters which are activated immediately
# after a crash occurs, comma separated.
#
#ActionsAndReporters = Mailx(\"[abrt] new crash was detected\")
#ActionsAndReporters = FileTransfer(\"store\")
ActionsAndReporters = SOSreport


# What actions or reporters to run on each crash type
#
[ AnalyzerActionsAndReporters ]
Kerneloops = RHTSupport, Logger
CCpp = RHTSupport, Logger
Python = RHTSupport, Logger
#CCpp:xorg-x11-apps = RunApp(\"date\", \"date.txt\")


# Which Action plugins to run repeatedly
#
[ Cron ]
#   h:m - at h:m
#   s - every s seconds

120 = KerneloopsScanner

#02:00 = FileTransfer
" = (
    {  }
    { " Common "
        { "#comment" = "With this option set to "yes"," }
        { "#comment" = "only crashes in signed packages will be analyzed." }
        { "#comment" = "the list of public keys used to check the signature is" }
        { "#comment" = "in the file gpg_keys" }
        { "#comment" }
        { "OpenGPGCheck" = "yes" }
        {  }
        { "#comment" = "Blacklisted packages" }
        { "#comment" }
        { "BlackList" = "nspluginwrapper, valgrind, strace, mono-core" }
        {  }
        { "#comment" = "Process crashes in executables which do not belong to any package?" }
        { "#comment" }
        { "ProcessUnpackaged" = "no" }
        {  }
        { "#comment" = "Blacklisted executable paths (shell patterns)" }
        { "#comment" }
        { "BlackListedPaths" = "/usr/share/doc/*, */example*, /usr/bin/nspluginviewer" }
        {  }
        { "#comment" = "Which database plugin to use" }
        { "#comment" }
        { "Database" = "SQLite3" }
        {  }
        { "#comment" = "Enable this if you want abrtd to auto-unpack crashdump tarballs which appear" }
        { "#comment" = "in this directory (for example, uploaded via ftp, scp etc)." }
        { "#comment" = "Note: you must ensure that whatever directory you specify here exists" }
        { "#comment" = "and is writable for abrtd. abrtd will not create it automatically." }
        { "#comment" }
        { "#comment" = "WatchCrashdumpArchiveDir = /var/spool/abrt-upload" }
        {  }
        { "#comment" = "Max size for crash storage [MiB] or 0 for unlimited" }
        { "#comment" }
        { "MaxCrashReportsSize" = "1000" }
        {  }
        { "#comment" = "Vector of actions and reporters which are activated immediately" }
        { "#comment" = "after a crash occurs, comma separated." }
        { "#comment" }
        { "#comment" = "ActionsAndReporters = Mailx("[abrt] new crash was detected")" }
        { "#comment" = "ActionsAndReporters = FileTransfer("store")" }
        { "ActionsAndReporters" = "SOSreport" }
        {  }
        {  }
        { "#comment" = "What actions or reporters to run on each crash type" }
        { "#comment" }
    }
    { " AnalyzerActionsAndReporters "
        { "Kerneloops" = "RHTSupport, Logger" }
        { "CCpp" = "RHTSupport, Logger" }
        { "Python" = "RHTSupport, Logger" }
        { "#comment" = "CCpp:xorg-x11-apps = RunApp("date", "date.txt")" }
        {  }
        {  }
        { "#comment" = "Which Action plugins to run repeatedly" }
        { "#comment" }
    }
    { " Cron "
        { "#comment" = "h:m - at h:m" }
        { "#comment" = "s - every s seconds" }
        {  }
        { "120" = "KerneloopsScanner" }
        {  }
        { "#comment" = "02:00 = FileTransfer" }
    }
)
