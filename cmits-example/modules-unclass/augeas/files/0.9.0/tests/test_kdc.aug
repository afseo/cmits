module Test_kdc =
   let lns = Kdc.lns
   let realms_enctypes = Kdc.realms_enctypes
   test realms_enctypes get " supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
" = 
  { "supported_enctypes"
    { "type" = "aes256-cts:normal" }
    { "type" = "aes128-cts:normal" }
    { "type" = "des3-hmac-sha1:normal" }
    { "type" = "arcfour-hmac:normal" }
    { "type" = "des-hmac-sha1:normal" }
    { "type" = "des-cbc-md5:normal" }
    { "type" = "des-cbc-crc:normal" }
  }


   test lns get "
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 EXAMPLE.COM = {
  #master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
 }
" = (
  {  }
  { "kdcdefaults"
    { "kdc_ports" = "88" }
    { "kdc_tcp_ports" = "88" }
    {  }
  }
  { "realms"
    { "realm" = "EXAMPLE.COM"
      { "#comment" = "master_key_type = aes256-cts" }
      { "acl_file" = "/var/kerberos/krb5kdc/kadm5.acl" }
      { "dict_file" = "/usr/share/dict/words" }
      { "admin_keytab" = "/var/kerberos/krb5kdc/kadm5.keytab" }
      { "supported_enctypes"
        { "type" = "aes256-cts:normal" }
        { "type" = "aes128-cts:normal" }
        { "type" = "des3-hmac-sha1:normal" }
        { "type" = "arcfour-hmac:normal" }
        { "type" = "des-hmac-sha1:normal" }
        { "type" = "des-cbc-md5:normal" }
        { "type" = "des-cbc-crc:normal" }
      }
    }
  }
)

    test lns put "" after 
        set "realms/realm[999]" "FOO.BAR.EXAMPLE.COM"
    = "[realms]
FOO.BAR.EXAMPLE.COM = {
}
"

    test lns put "[realms]
FOO.BAR.EXAMPLE.COM = {
}" after 
        set "realms/realm[.='FOO.BAR.EXAMPLE.COM']/acl_file" "/var/kerberos/krb5kdc/kadm5.acl"
    = "[realms]
FOO.BAR.EXAMPLE.COM = {
acl_file = /var/kerberos/krb5kdc/kadm5.acl
}
"

