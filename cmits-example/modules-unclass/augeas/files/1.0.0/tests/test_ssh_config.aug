module Test_ssh_config =
    let host = Ssh_config.host
    let anything_but_host = Ssh_config.anything_but_host
    let toplevel_stanza = Ssh_config.toplevel_stanza
    let host_stanza = Ssh_config.host_stanza
    let lns = Ssh_config.lns

    test [host] get "Host *\n" =
        { "Host" = "*" }
    test [host] get "Host *.co.uk\n" =
        { "Host" = "*.co.uk" }
    test [host] get "Host 192.168.0.?\n" = 
        { "Host" = "192.168.0.?" }
    test [host] get "host foo.example.com\n" =
        { "Host" = "foo.example.com" }
    test [host] get "   hOsT flarble\n" =
        { "Host" = "flarble" }


    test [anything_but_host] get "F 1\n" =
        { "F" = "1" }
    test [anything_but_host] get "BindAddress 127.0.0.1\n" =
        { "BindAddress" = "127.0.0.1" }
    test [anything_but_host] get "ForYou two words\n" =
        { "ForYou" = "two words" }


    test toplevel_stanza get "Line 1
                              User flarble
                              # A comment

                              Key Value\n" = 
        { "toplevel"
            { "Line" = "1" }
            { "User" = "flarble" }
            { "#comment" = "A comment" }
            {  }
            { "Key" = "Value" }
        }

    test host_stanza get "Host mumble
                              User flarble
                              # A comment
                              
                              Key Value\n" =
        { "Host" = "mumble"
            { "User" = "flarble" }
            { "#comment" = "A comment" }
            {  }
            { "Key" = "Value" }
        }

    (* keys can contain digits! *)
    test host_stanza get "Host *
                      User flarble
                      GSSAPIAuthentication yes
                      ForwardX11Trusted yes\n" =
        { "Host" = "*"
            { "User" = "flarble" }
            { "GSSAPIAuthentication" = "yes" }
            { "ForwardX11Trusted" = "yes" }
        }


    test lns get "
#	$OpenBSD: ssh_config,v 1.25 2009/02/17 01:28:32 djm Exp $

# This is the ssh client system-wide configuration file.  See
# ssh_config(5) for more information.  This file provides defaults for
# users, and the values can be changed in per-user configuration files
# or on the command line.

# Configuration data is parsed as follows:
#  1. command line options
#  2. user-specific file
#  3. system-wide file
# Any configuration value is only changed the first time it is set.
# Thus, host-specific definitions should be at the beginning of the
# configuration file, and defaults at the end.

# Site-wide defaults for some commonly used options.  For a comprehensive
# list of available options, their meanings and defaults, please see the
# ssh_config(5) man page.

# Host *
#   ForwardAgent no
#   ForwardX11 no
#   RhostsRSAAuthentication no
#   RSAAuthentication yes
#   PasswordAuthentication yes
#   HostbasedAuthentication no
#   GSSAPIAuthentication no
#   GSSAPIDelegateCredentials no
#   GSSAPIKeyExchange no
#   GSSAPITrustDNS no
#   BatchMode no
#   CheckHostIP yes
#   AddressFamily any
#   ConnectTimeout 0
#   StrictHostKeyChecking ask
#   IdentityFile ~/.ssh/identity
#   IdentityFile ~/.ssh/id_rsa
#   IdentityFile ~/.ssh/id_dsa
#   Port 22
#   Protocol 2,1
#   Cipher 3des
#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160
#   EscapeChar ~
#   Tunnel no
#   TunnelDevice any:any
#   PermitLocalCommand no
#   VisualHostKey no
Host *
	GSSAPIAuthentication yes
# If this option is set to yes then remote X11 clients will have full access
# to the original X11 display. As virtually no X11 client supports the untrusted
# mode correctly we set this to yes.
	ForwardX11Trusted yes
# Send locale-related environment variables
	SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES 
	SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT 
	SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
	SendEnv XMODIFIERS
" = 

    { "toplevel"
        {  }
        { "#comment" = "$OpenBSD: ssh_config,v 1.25 2009/02/17 01:28:32 djm Exp $" }
        {  }
        { "#comment" = "This is the ssh client system-wide configuration file.  See" }
        { "#comment" = "ssh_config(5) for more information.  This file provides defaults for" }
        { "#comment" = "users, and the values can be changed in per-user configuration files" }
        { "#comment" = "or on the command line." }
        {  }
        { "#comment" = "Configuration data is parsed as follows:" }
        { "#comment" = "1. command line options" }
        { "#comment" = "2. user-specific file" }
        { "#comment" = "3. system-wide file" }
        { "#comment" = "Any configuration value is only changed the first time it is set." }
        { "#comment" = "Thus, host-specific definitions should be at the beginning of the" }
        { "#comment" = "configuration file, and defaults at the end." }
        {  }
        { "#comment" = "Site-wide defaults for some commonly used options.  For a comprehensive" }
        { "#comment" = "list of available options, their meanings and defaults, please see the" }
        { "#comment" = "ssh_config(5) man page." }
        {  }
        { "#comment" = "Host *" }
        { "#comment" = "ForwardAgent no" }
        { "#comment" = "ForwardX11 no" }
        { "#comment" = "RhostsRSAAuthentication no" }
        { "#comment" = "RSAAuthentication yes" }
        { "#comment" = "PasswordAuthentication yes" }
        { "#comment" = "HostbasedAuthentication no" }
        { "#comment" = "GSSAPIAuthentication no" }
        { "#comment" = "GSSAPIDelegateCredentials no" }
        { "#comment" = "GSSAPIKeyExchange no" }
        { "#comment" = "GSSAPITrustDNS no" }
        { "#comment" = "BatchMode no" }
        { "#comment" = "CheckHostIP yes" }
        { "#comment" = "AddressFamily any" }
        { "#comment" = "ConnectTimeout 0" }
        { "#comment" = "StrictHostKeyChecking ask" }
        { "#comment" = "IdentityFile ~/.ssh/identity" }
        { "#comment" = "IdentityFile ~/.ssh/id_rsa" }
        { "#comment" = "IdentityFile ~/.ssh/id_dsa" }
        { "#comment" = "Port 22" }
        { "#comment" = "Protocol 2,1" }
        { "#comment" = "Cipher 3des" }
        { "#comment" = "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc" }
        { "#comment" = "MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160" }
        { "#comment" = "EscapeChar ~" }
        { "#comment" = "Tunnel no" }
        { "#comment" = "TunnelDevice any:any" }
        { "#comment" = "PermitLocalCommand no" }
        { "#comment" = "VisualHostKey no" }
    }
    { "Host" = "*"
        { "GSSAPIAuthentication" = "yes" }
        { "#comment" = "If this option is set to yes then remote X11 clients will have full access" }
        { "#comment" = "to the original X11 display. As virtually no X11 client supports the untrusted" }
        { "#comment" = "mode correctly we set this to yes." }
        { "ForwardX11Trusted" = "yes" }
        { "#comment" = "Send locale-related environment variables" }
        { "SendEnv" = "LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES" }
        { "SendEnv" = "LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT" }
        { "SendEnv" = "LC_IDENTIFICATION LC_ALL LANGUAGE" }
        { "SendEnv" = "XMODIFIERS" }
    }

