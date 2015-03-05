module Test_up2date =
    let akey = Up2date.akey
    let avalue = Up2date.avalue
    let setting = Up2date.setting
    let lns = Up2date.lns

    test [key akey] get "hP[c]" = { "hP[c]" }

    test [store avalue] get "foo" = { = "foo" }
    test [store avalue] get "" = { = "" }

    test setting get 
        "hP[c]=H py i ht:p ft, e.g. sqd.rt.c:3128\n" =
        { "hP[c]" = "H py i ht:p ft, e.g. sqd.rt.c:3128" }
    test setting get "foo=\n" = { "foo" = "" }

    test lns get
"# Automatically generated Red Hat Update Agent config file, do not edit.
# Format: 1.0
tmpDir[comment]=Use this Directory to place the temporary transport files
tmpDir=/tmp

disallowConfChanges[comment]=Config options that can not be overwritten by a config update action
disallowConfChanges=noReboot;sslCACert;useNoSSLForPackages;noSSLServerURL;serverURL;disallowConfChanges;

skipNetwork[comment]=Skips network information in hardware profile sync during registration.
skipNetwork=0

networkRetries[comment]=Number of attempts to make at network connections before giving up
networkRetries=1

hostedWhitelist[comment]=RHN Hosted URL's
hostedWhitelist=

enableProxy[comment]=Use a HTTP Proxy
enableProxy=0

writeChangesToLog[comment]=Log to /var/log/up2date which packages has been added and removed
writeChangesToLog=0

serverURL[comment]=Remote server URL
serverURL=https://xmlrpc.rhn.redhat.com/XMLRPC

proxyPassword[comment]=The password to use for an authenticated proxy
proxyPassword=

networkSetup[comment]=None
networkSetup=1

proxyUser[comment]=The username for an authenticated proxy
proxyUser=

versionOverride[comment]=Override the automatically determined system version
versionOverride=

sslCACert[comment]=The CA cert used to verify the ssl server
sslCACert=/usr/share/rhn/RHNS-CA-CERT

retrieveOnly[comment]=Retrieve packages only
retrieveOnly=0

debug[comment]=Whether or not debugging is enabled
debug=0

httpProxy[comment]=HTTP proxy in host:port format, e.g. squid.redhat.com:3128
httpProxy=

systemIdPath[comment]=Location of system id
systemIdPath=/etc/sysconfig/rhn/systemid

enableProxyAuth[comment]=To use an authenticated proxy or not
enableProxyAuth=0

noReboot[comment]=Disable the reboot actions
noReboot=0
" = ( 
        { "#comment" = "Automatically generated Red Hat Update Agent config file, do not edit." }
        { "#comment" = "Format: 1.0" }
        { "tmpDir[comment]" = "Use this Directory to place the temporary transport files" }
        { "tmpDir" = "/tmp" }
        {  }
        { "disallowConfChanges[comment]" = "Config options that can not be overwritten by a config update action" }
        { "disallowConfChanges" = "noReboot;sslCACert;useNoSSLForPackages;noSSLServerURL;serverURL;disallowConfChanges;" }
        {  }
        { "skipNetwork[comment]" = "Skips network information in hardware profile sync during registration." }
        { "skipNetwork" = "0" }
        {  }
        { "networkRetries[comment]" = "Number of attempts to make at network connections before giving up" }
        { "networkRetries" = "1" }
        {  }
        { "hostedWhitelist[comment]" = "RHN Hosted URL's" }
        { "hostedWhitelist" = "" }
        {  }
        { "enableProxy[comment]" = "Use a HTTP Proxy" }
        { "enableProxy" = "0" }
        {  }
        { "writeChangesToLog[comment]" = "Log to /var/log/up2date which packages has been added and removed" }
        { "writeChangesToLog" = "0" }
        {  }
        { "serverURL[comment]" = "Remote server URL" }
        { "serverURL" = "https://xmlrpc.rhn.redhat.com/XMLRPC" }
        {  }
        { "proxyPassword[comment]" = "The password to use for an authenticated proxy" }
        { "proxyPassword" = "" }
        {  }
        { "networkSetup[comment]" = "None" }
        { "networkSetup" = "1" }
        {  }
        { "proxyUser[comment]" = "The username for an authenticated proxy" }
        { "proxyUser" = "" }
        {  }
        { "versionOverride[comment]" = "Override the automatically determined system version" }
        { "versionOverride" = "" }
        {  }
        { "sslCACert[comment]" = "The CA cert used to verify the ssl server" }
        { "sslCACert" = "/usr/share/rhn/RHNS-CA-CERT" }
        {  }
        { "retrieveOnly[comment]" = "Retrieve packages only" }
        { "retrieveOnly" = "0" }
        {  }
        { "debug[comment]" = "Whether or not debugging is enabled" }
        { "debug" = "0" }
        {  }
        { "httpProxy[comment]" = "HTTP proxy in host:port format, e.g. squid.redhat.com:3128" }
        { "httpProxy" = "" }
        {  }
        { "systemIdPath[comment]" = "Location of system id" }
        { "systemIdPath" = "/etc/sysconfig/rhn/systemid" }
        {  }
        { "enableProxyAuth[comment]" = "To use an authenticated proxy or not" }
        { "enableProxyAuth" = "0" }
        {  }
        { "noReboot[comment]" = "Disable the reboot actions" }
        { "noReboot" = "0" }
    )

