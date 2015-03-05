# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
#
# The tests in this module deal with CA certificates and CRLs. Rather
# than create a CA and issue a CRL at test time, I've used a DoD CA
# certificate and a real CRL. This saves work in the short term, but
# it means that in a couple of years, the tests will start failing
# even though the code has not changed.

import unittest
import tempfile
import shutil
import os
import base64
import datetime
from subprocess import Popen, PIPE
from refresh_crls_nss import NSSDB, CACert, splitOnUnquotedCommas, CRL

class TestSplitOnUnquotedCommas(unittest.TestCase):
    def testSplitNoQuotes(self):
        self.assertEqual(splitOnUnquotedCommas('a,b,c,d,e'), 
                ['a', 'b', 'c', 'd', 'e'])

    def testSplitWithQuotes(self):
        self.assertEqual(splitOnUnquotedCommas('a,"b,c",d,e'),
                ['a', '"b,c"', 'd', 'e'])

    def testSplitDNWithQuotes(self):
        self.assertEqual(splitOnUnquotedCommas(
            'CN="Bletch, Quux, Zart",OU="Foo, Bar, Baz",' \
            'O="Goo, Bar, Baz",L=fi,ST=gb,C=us'),
            ['CN="Bletch, Quux, Zart"', 'OU="Foo, Bar, Baz"',
                'O="Goo, Bar, Baz"', 'L=fi', 'ST=gb', 'C=us'])

class CommonDataForTest(object):
    certs = {
            'DoD-Root2-CA32': """\
-----BEGIN CERTIFICATE-----
MIIFTDCCBDSgAwIBAgICA6EwDQYJKoZIhvcNAQEFBQAwWzELMAkGA1UEBhMCVVMx
GDAWBgNVBAoTD1UuUy4gR292ZXJubWVudDEMMAoGA1UECxMDRG9EMQwwCgYDVQQL
EwNQS0kxFjAUBgNVBAMTDURvRCBSb290IENBIDIwHhcNMTMwMjA0MjA0NDA1WhcN
MTkwMjA0MjA0NDA1WjBXMQswCQYDVQQGEwJVUzEYMBYGA1UEChMPVS5TLiBHb3Zl
cm5tZW50MQwwCgYDVQQLEwNEb0QxDDAKBgNVBAsTA1BLSTESMBAGA1UEAxMJRE9E
IENBLTMyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs+KVHZM2LSWl
Dv146e/qk9E6ydhXvRnf0cei0ejZ/dKOFajdvT5k9Lb+nAPfS7Blt6sEGDIZbBMB
UtHmtchBEre+O8tNQBCIyp62/TV3bSb2ZK0RhwypJXpYn7C9mPaTXxvv77KXrfgV
59zmoGp1DVHfVR1oQVJJLsecaFdWR4/e9lIugW9WvAaJEpSfI70/gceGAnUwXjOh
3OETu/15VgE8Shn0LOuQZGTX6AovUYbVCJuE+/npi0LKZdKQBxyCl4xEI1cGLHVp
KHCy7T5M1eOWdxX9upXPW5ZpAnfWgNmPhynj5wV2r8qNEmA0cseznThuTJYynpA1
rXWL0WJACQIDAQABo4ICHDCCAhgwHQYDVR0OBBYEFC/Kk1MDrG919Xb6vv6O6hCL
t+eQMB8GA1UdIwQYMBaAFEl0uwxeunr+AlTve6DGlcYJgHCWMBIGA1UdEwEB/wQI
MAYBAf8CAQAwDAYDVR0kBAUwA4ABADAOBgNVHQ8BAf8EBAMCAYYwZgYDVR0gBF8w
XTALBglghkgBZQIBCwUwCwYJYIZIAWUCAQsJMAsGCWCGSAFlAgELETALBglghkgB
ZQIBCxIwCwYJYIZIAWUCAQsTMAwGCmCGSAFlAwIBAxowDAYKYIZIAWUDAgEDGzA3
BgNVHR8EMDAuMCygKqAohiZodHRwOi8vY3JsLmRpc2EubWlsL2NybC9ET0RST09U
Q0EyLmNybDCCAQEGCCsGAQUFBwEBBIH0MIHxMDoGCCsGAQUFBzAChi5odHRwOi8v
Y3JsLmRpc2EubWlsL2lzc3VlZHRvL0RPRFJPT1RDQTJfSVQucDdjMCAGCCsGAQUF
BzABhhRodHRwOi8vb2NzcC5kaXNhLm1pbDCBkAYIKwYBBQUHMAKGgYNsZGFwOi8v
Y3JsLmdkcy5kaXNhLm1pbC9jbiUzZERvRCUyMFJvb3QlMjBDQSUyMDIlMmNvdSUz
ZFBLSSUyY291JTNkRG9EJTJjbyUzZFUuUy4lMjBHb3Zlcm5tZW50JTJjYyUzZFVT
P2Nyb3NzQ2VydGlmaWNhdGVQYWlyO2JpbmFyeTANBgkqhkiG9w0BAQUFAAOCAQEA
MI3VVmO9mQaLTbbSDgO5xoTSm3dBGojS/8Pa4uZnYb3Zeu04OV6rC1g0+droYnmv
OXLzSqfjTjkQzenSCOrUnpqnNTWTkwJZ4kwAHPP8ayFTSoxh52HL0EYL0T+cafXv
UIrwQLMrVloda2JZBbOPJxgFCkNbAu/dUl5bwKkcVuOVbJdPAYNWcl3XfVHjWlQu
uJj9ck4lj4sW0bDhM+OSfBBVMyRmrw8zBlNIA4eftGR0tdI9InK30Y43ERM5357n
0AwLilkRMmX/9rlGvT82nqeUAFfwwBnhLNxM9y9MkB1D764I43OeOr+Z7CK5B1iu
2TVSS1G7gTaPn24hCqaOhw==
-----END CERTIFICATE-----
""",
            'commasInName': """\
-----BEGIN CERTIFICATE-----
MIIDuzCCAqOgAwIBAgIJALN9MAh64NFXMA0GCSqGSIb3DQEBBQUAMHQxCzAJBgNV
BAYTAnVzMQswCQYDVQQIDAJnYjELMAkGA1UEBwwCZmkxFjAUBgNVBAoMDUdvbywg
QmFyLCBCYXoxFjAUBgNVBAsMDUZvbywgQmFyLCBCYXoxGzAZBgNVBAMMEkJsZXRj
aCwgUXV1eCwgWmFydDAeFw0xMTA5MTMxNDI4MjFaFw0xMjA5MTIxNDI4MjFaMHQx
CzAJBgNVBAYTAnVzMQswCQYDVQQIDAJnYjELMAkGA1UEBwwCZmkxFjAUBgNVBAoM
DUdvbywgQmFyLCBCYXoxFjAUBgNVBAsMDUZvbywgQmFyLCBCYXoxGzAZBgNVBAMM
EkJsZXRjaCwgUXV1eCwgWmFydDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBANHNk3810A+83PPpli+Qeml4I4S9A6LTN9WjJjbQUEQmFBEqNaCh9DTJ+JeT
WPijvEqyBRPNxX8u//EyGSxZJGjAqwXK2pXhchUj7PnfwGTOZbIQRQRrqGCkL7r1
Y4ofz8TjPW5FI2wnRb0R54U7RMeDGOLOPSYKosZKqVeZ5ZYJ+gbfHqqBOolcZQZS
ijZrajGCeB+zvwwias7R6/91YZ7lbcQxxKcnidaSlXeR+UvC3nGgEJIpFQ/ODPvo
J8DW+JTaXAsHJB7LU3yJWssj94o9NZJbT1pF1ZF1AKdWWPA+rAUqLNChDsrQbLAb
060ES02u6ZdAwUfdg4oLydiyiQ0CAwEAAaNQME4wHQYDVR0OBBYEFBRZmPynr7eR
1tVpQ9XYYhqgzNhuMB8GA1UdIwQYMBaAFBRZmPynr7eR1tVpQ9XYYhqgzNhuMAwG
A1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBADSildV6BTLUAaJ7c/TCGtQ/
Q+EWnW9EpK/AKekd7Lex8YNcfkJHDtkRwmuCE9xHtPosBlRgN7w3FGhCAilZ4A+h
aaiVSdTh18lVN474t8c1PxTRJBz1aNRdG5UMpznjwhsTCIKQXfs6qr761DU1SE7a
hJqaVh0quiNcYYeXrN8SAQefdFQCKwhbkeH4UocCqOpDcsDeSDXQw05IiAtEHRKg
VQS6c2wa4yjQAypQQeTl/ceXqx3zyh67wojWnzJ0MosPuc+kFKqRa/+pZrRfr2Z+
vQ/h/2mAJMBalFiI0OFU+egI2HeMGXF6zcSYIy09bQ1X880iJ/PYGrG6ZGUlZQA=
-----END CERTIFICATE-----
""",
        'commasAndSpaces': """\
-----BEGIN CERTIFICATE-----
MIIDwzCCAqugAwIBAgIJAL0lAvUxQACRMA0GCSqGSIb3DQEBBQUAMHgxCzAJBgNV
BAYTAnVzMQswCQYDVQQIDAJnYjELMAkGA1UEBwwCZmkxGjAYBgNVBAoMEUdvbywg
QmFyLCAgICAgQmF6MRYwFAYDVQQLDA1Gb28sIEJhciwgQmF6MRswGQYDVQQDDBJC
bGV0Y2gsIFF1dXgsIFphcnQwHhcNMTEwOTEzMTUwMzUzWhcNMTIwOTEyMTUwMzUz
WjB4MQswCQYDVQQGEwJ1czELMAkGA1UECAwCZ2IxCzAJBgNVBAcMAmZpMRowGAYD
VQQKDBFHb28sIEJhciwgICAgIEJhejEWMBQGA1UECwwNRm9vLCBCYXIsIEJhejEb
MBkGA1UEAwwSQmxldGNoLCBRdXV4LCBaYXJ0MIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAvu+nbGuAubKXN8Ivg6t+OKEOK0zz4XOIxYNuWuFXdqUM5VJz
+yD7EgHbq0rulY2jjaGkPil24W1fiy5tBbcRFEvhZYek9SqgNOMU6twhKSsUhhuC
k5y07A1BYBxsZh+JbZ1WQnKjIjPewOKueOjAOvOZYyyZxdijMAfKb9CVqxIx0iiF
rKGe3LptQYpzIXjJGuHtZNz/hVY/RajHKoYmH6E9qDemjoVoEmfDY664Q2uS8jGD
2U+SExvQEFWLit0YMbYJ+2syxc4W7OQPr8746Khw+eCvuM/6kPHZmkrVHgLP1+j1
Iwdh0h0DBcZ+zWuN+B4kRvH6UVtRtxeW3/dnrwIDAQABo1AwTjAdBgNVHQ4EFgQU
nLnn2aMlIzvMocHBLAZoBKGM/gowHwYDVR0jBBgwFoAUnLnn2aMlIzvMocHBLAZo
BKGM/gowDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOCAQEAPYTqTq9zQJbg
3sczgc35aq0O9neVorFlA/d7oDqRgR439PNbrBjM0uaE49+Lhp+1x3f8KIVmc5fW
cgK7UQS1cvIn4JY3Q+6uv92FntHWLc5WRsC3YmtOZNYZtXG5ouMJyPIIQ7y6VoIS
DuzxnNYL7OHFSGZXTAomwOoJiNK13imBI6Bgb6GBPbxo7x9N21b2/gqKugA2ReYc
edEIJ6A+kSylAVgn0LtOWmUopSfhZaFx0tx8mpyQmE6G3tDGHIXe6LSlUzqEwWXe
C8G+2BnGb2Q45yamokhLE0K7U8jfjDZ7RyO6K9l6GcuaFUDFRstb1/znXMn90NaZ
LBon4kaikA==
-----END CERTIFICATE-----
"""
    }

    # this one is long. go ahead and scroll down. or, in vim, use the
    # } command. or in emacs, M-}. crlutil expects a CRL in DER format
    # so we'll have to b64decode this.
    ca32CRL = """\
-----BEGIN X509 CRL-----
MIIcITCCGwkCAQEwDQYJKoZIhvcNAQEFBQAwVzELMAkGA1UEBhMCVVMxGDAWBgNV
BAoTD1UuUy4gR292ZXJubWVudDEMMAoGA1UECxMDRG9EMQwwCgYDVQQLEwNQS0kx
EjAQBgNVBAMTCURPRCBDQS0zMhcNMTMwOTIzMDgwMDAwWhcNMTMwOTMwMTcwMDAw
WjCCGkowEwICC/gXDTEzMDkxMDEzNDM0MlowEwICHfAXDTEzMDkxNzEzMTcxNFow
EwICHegXDTEzMDkxNzEzMzAzNFowEwICEekXDTEzMDkxMDE0MzgzMFowEwICI+MX
DTEzMDkxNjE4NTg0MVowEwICBewXDTEzMDkxNjEyNDcwOVowEwICEegXDTEzMDkw
OTIzMDY1MFowEwICBeoXDTEzMDkxMDExNTE0MFowEwICBegXDTEzMDkwOTIwMDE0
NFowEwICEeIXDTEzMDkxNzE1MjkzOVowEwICJtsXDTEzMDkxNjEyMjAyNlowEwIC
FOAXDTEzMDkxNzAxMjc0OFowEwICC98XDTEzMDkxMDEzNTUyMlowEwICFNkXDTEz
MDkxNzAxMjc1MFowEwICDtcXDTEzMDkxMDEyNTYyM1owEwICI9AXDTEzMDkxNjEx
NTIzOVowEwICEcwXDTEzMDkxNzE1Mjk0MVowEwICFMsXDTEzMDkxMDAzMjY0MFow
EwICHcYXDTEzMDkxNzEzMTcxNlowEwICFMcXDTEzMDkxMDAzMjY0MlowEwICBccX
DTEzMDkwOTIwMDE0NVowEwICJrsXDTEzMDkxNzE2MTcxNVowEwICC7kXDTEzMDkx
MDEzNTUyNFowEwICDrUXDTEzMDkxMDEyNTYyNVowEwICCLYXDTEzMDkwOTE4Mjcy
OFowEwICJqsXDTEzMDkxNjE0Mzg0MVowEwICBbMXDTEzMDkxNjEyNDcxMVowEwIC
FK4XDTEzMDkxNTIzMTQ1MFowEwICEawXDTEzMDkwOTIwMzgyM1owEwICJqUXDTEz
MDkxMDE0NDI1MFowEwICBa8XDTEzMDkxMDExNTE0MlowEwICFKgXDTEzMDkxNTIz
MTQ1MVowEwICCKAXDTEzMDkwOTE4MjczMFowEwICApwXDTEzMDkwOTIwMDgyM1ow
EwICBZsXDTEzMDkwOTE4NTYyNVowEwICC5cXDTEzMDkwOTE5MDcyNlowEwICApkX
DTEzMDkwOTIwMDgyNVowEwICJo0XDTEzMDkxNzE2MTcxN1owEwICJooXDTEzMDkx
NjE0Mzg0MlowEwICEZAXDTEzMDkwOTIwMzgyNVowEwICApEXDTEzMDkxMDEyNTU0
MFowEwICJoQXDTEzMDkxMDE0NDI0OFowEwICCIsXDTEzMDkxMDEwMTc0MFowEwIC
F4IXDTEzMDkxMDA3Mjg0MFowEwICAoYXDTEzMDkxMDEyNTU0MlowEwICBYUXDTEz
MDkwOTE4NTYyN1owEwICF38XDTEzMDkxMDA3Mjg0MlowEwICEXgXDTEzMDkxMDE0
MzcxMFowEwICIG8XDTEzMDkxNzEyNTc0NlowEwICAncXDTEzMDkwOTE3MTUxNVow
EwICC3MXDTEzMDkxMDEzNTc0OFowEwICAnUXDTEzMDkwOTE3MTUxN1owEwICC3AX
DTEzMDkwOTE5MDcyOFowEwICEW0XDTEzMDkxMDE0MzcxMlowEwICI2IXDTEzMDkx
MDE0MDkzOFowEwICI18XDTEzMDkxNjEzMTA0MlowEwICIFUXDTEzMDkxNjE3NTgw
N1owEwICC1gXDTEzMDkxMDEzNTc0OVowEwICDk0XDTEzMDkxNzE1MDYzNlowEwIC
IEMXDTEzMDkxNzEyNTc0OFowEwICAkMXDTEzMDkxMDExMzcyNVowEwICHTgXDTEz
MDkxMDE1MDQ0NFowEwICAj0XDTEzMDkxMDExMzcyN1owEwICIzIXDTEzMDkxNjEx
MzYwM1owEwICHTIXDTEzMDkxNjEyNTAxOFowEwICIDEXDTEzMDkxNjE3NTgwOVow
EwICCDUXDTEzMDkxMDEwMTc0MlowEwICGi8XDTEzMDkxMDEyMDExNVowEwICBTUX
DTEzMDkwOTE4NTkxMlowEwICGi0XDTEzMDkxNzExMTk1MFowEwICHSwXDTEzMDkx
NjEyNTkzMVowEwICIyYXDTEzMDkxNzE1MzIwMVowEwICBS0XDTEzMDkxMDEzMDg1
MlowEwICDicXDTEzMDkxNzE1MDYzOFowEwICIyAXDTEzMDkxNjEzMTA0NFowEwIC
GiAXDTEzMDkxMDEyMDExM1owEwICGh8XDTEzMDkxNzExMTk1MlowEwICESEXDTEz
MDkwOTIwMzAyMVowEwICDiEXDTEzMDkxMDEzNTgyOVowEwICBSAXDTEzMDkwOTE4
NTkxNFowEwICHRgXDTEzMDkxMDE1MDQ0NVowEwICIxYXDTEzMDkxMDE0NDYyOFow
EwICGhQXDTEzMDkxMDEyMDU0M1owEwICIw8XDTEzMDkxNjExMzYwNlowEwICGgwX
DTEzMDkxNzE0NTA1MlowEwICIwgXDTEzMDkxNzE1MzIwM1owEwICEQwXDTEzMDkx
NzE1MDgzMVowEwICEQkXDTEzMDkwOTIwMzAyM1owEwICAgsXDTEzMDkwOTExMDk0
M1owEwICFAQXDTEzMDkwOTIyMTA0NVowEwICAgkXDTEzMDkwOTExMDk0MFowEwIC
BQcXDTEzMDkxMDEzMDg1NFowEwICCAYXDTEzMDkxNjE4MDUzOVowEwICHP8XDTEz
MDkxNjEyNTkzM1owEwICE/4XDTEzMDkwOTIyMTA0N1owEwICHPkXDTEzMDkxNjEy
NTIxOVowEwICBQAXDTEzMDkxNjEyMjM0OVowEwICDfoXDTEzMDkxMDEzNTgzMVow
EwICEPUXDTEzMDkxNzE1MDgzMlowEwICGfEXDTEzMDkxNjE1MjE0OFowEwICGe8X
DTEzMDkxNzE0NTA1NFowEwICB/IXDTEzMDkxMDEyNTc1NVowEwICAfIXDTEzMDkx
MDExNDg0NlowEwICB/AXDTEzMDkwOTE4MTQzMVowEwICBO8XDTEzMDkwOTE4NTQw
M1owEwICAe4XDTEzMDkxMDExNDg0OFowEwICBO0XDTEzMDkxNjEyMjM1MFowEwIC
B+wXDTEzMDkxNjE4MDU0MVowEwICDegXDTEzMDkxMDEyMzU0OVowEwICAeUXDTEz
MDkxMDA5MzkxMlowEwICAeIXDTEzMDkxMDA5MzkxNFowEwICEN0XDTEzMDkwOTIy
NDM1MlowEwICCtsXDTEzMDkwOTE5MDQwOFowEwICDdIXDTEzMDkxMDEyMzU1Mlow
EwICGcgXDTEzMDkxNjE1MjE1MFowEwICIsUXDTEzMDkxMDE0MDIwM1owEwICBM4X
DTEzMDkwOTE4NTQwNVowEwICB8cXDTEzMDkwOTE4MTQyOFowEwICIr4XDTEzMDkx
MDE0NDYzMFowEwICB7QXDTEzMDkxMDEyNTc1N1owEwICFqwXDTEzMDkxNzA5MzYy
N1owEwICDa4XDTEzMDkxNjE2MTYyN1owEwICFqkXDTEzMDkxNzA5MzYyOVowEwIC
DZ8XDTEzMDkxMDE0MTQyOVowEwICDZYXDTEzMDkxMDEzNTQxOFowEwICH4oXDTEz
MDkxNjEyMDkzN1owEwICJYgXDTEzMDkxMDE0NDQxOVowEwICDY8XDTEzMDkxMDEy
MDg0MVowEwICCo8XDTEzMDkwOTE5MDQxMFowEwICBI8XDTEzMDkwOTE3MjE0Nlow
EwICBI0XDTEzMDkwOTE5NTA1NFowEwICDYoXDTEzMDkxNjE2MTYyOVowEwICJYIX
DTEzMDkxMDE0MzUxNlowEwICE4cXDTEzMDkxMDExNDQyMFowEwICIoEXDTEzMDkx
MDE0MDIwNVowEwICE4AXDTEzMDkxMDExNDQyMVowEwICEH4XDTEzMDkwOTIwMjUw
NVowEwICAX8XDTEzMDkxMDA4NDU1MFowEwICH3MXDTEzMDkxNjEyMDkzOVowEwIC
AXwXDTEzMDkxNzAyNDA1NVowEwICB3gXDTEzMDkxMDEyNTgyM1owEwICAXkXDTEz
MDkxMDA4NDU1MlowEwICDXQXDTEzMDkwOTIzNTcxMlowEwICAXcXDTEzMDkxNzAy
NDA1N1owEwICBHYXDTEzMDkwOTE3MjE0OFowEwICImsXDTEzMDkxNjE4NTEzNlow
EwICAXYXDTEzMDkxMDA5MTI0N1owEwICH2sXDTEzMDkxNzE1NDE1OVowEwICAXUX
DTEzMDkxMDA5MTI0OVowEwICDXEXDTEzMDkxMDEyMDg0NFowEwICDXAXDTEzMDkx
NjE0MTczOFowEwICEGwXDTEzMDkwOTIwMjUwNlowEwICJWQXDTEzMDkxMDE0MzYx
MFowEwICDWoXDTEzMDkxMDEzNTQyMFowEwICAWwXDTEzMDkxNzEyMzAxM1owEwIC
AWkXDTEzMDkxNzEyMzAxNVowEwICDWQXDTEzMDkxMDE0MTQzMVowEwICJVcXDTEz
MDkxMDE0NDQyMVowEwICBGEXDTEzMDkwOTE5NTA1NlowEwICAV8XDTEzMDkxMDA3
MzU1OVowEwICJVMXDTEzMDkxMDE0MjgwNlowEwICE1UXDTEzMDkwOTIyMjU0OFow
EwICIlAXDTEzMDkxNjE4NTEzOFowEwICAVgXDTEzMDkxMDA3MzYwMVowEwICAVMX
DTEzMDkxMDAzMDQ0MFowEwICIkcXDTEzMDkxMDEzNTcxM1owEwICIkUXDTEzMDkx
NjEzNTQ0M1owEwICAU8XDTEzMDkxMDAzMDQ0MlowEwICCkoXDTEzMDkxMDEzNDUz
MlowEwICDUkXDTEzMDkxNjE0MTc0MFowEwICH0IXDTEzMDkxNzE1NDIwMVowEwIC
GToXDTEzMDkxMDEzNTUzMlowEwICCj4XDTEzMDkxMDE0MDAzMFowEwICEDsXDTEz
MDkxNjExNTIyNVowEwICEzkXDTEzMDkwOTIyMjU1MFowEwICHzUXDTEzMDkxNzEy
NTgxMVowEwICGTUXDTEzMDkxMDE0Mjg1NVowEwICFjAXDTEzMDkxMDAzMzI1MVow
EwICBzMXDTEzMDkxMDEyNTgyNVowEwICGSwXDTEzMDkxMDEzNTUzNFowEwICFiwX
DTEzMDkxMDAzMzI1M1owEwICDSwXDTEzMDkwOTIzNTcxNFowEwICGSYXDTEzMDkx
MDE0Mjg1N1owEwICJSAXDTEzMDkxMDE0MjgwOFowEwICECUXDTEzMDkxNjExNTIy
NlowEwICBCAXDTEzMDkxNjE3MTQyN1owEwICHxYXDTEzMDkxNjEyMTgzOFowEwIC
HxQXDTEzMDkxNzEyNTgxM1owEwICChoXDTEzMDkxMDEzNDUzNFowEwICExMXDTEz
MDkxNzE0MDY1OFowEwICBBYXDTEzMDkxMDE0NDQwM1owEwICBxAXDTEzMDkwOTE5
MTYyNFowEwICKAMXDTEzMDkxNjIwMDAwMlowEwICKAIXDTEzMDkxNDAxMzYyNFow
EwICKAEXDTEzMDkxNDAxMzYyNFowEwICKAAXDTEzMDkxNDAxMzYyNFowEwICJ/8X
DTEzMDkxNDAxMzYyNFowEwICJ/4XDTEzMDkxNDAxMzYyNFowEwICEwQXDTEzMDkw
OTIzMjcxMlowEwICJ/0XDTEzMDkxNDAxMzYyNFowEwICJ/wXDTEzMDkxNDAxMzYy
NFowEwICIf0XDTEzMDkxNjEzNTQ0NVowEwICEwEXDTEzMDkxNzE0MDcwMFowEwIC
BAAXDTEzMDkxMDE0NDQwNVowEwICA/sXDTEzMDkxNjE3MTQyOVowEwICCfkXDTEz
MDkxMDE0MDAzMlowEwICEvYXDTEzMDkwOTIzMjcxNFowEwICHucXDTEzMDkxNjEy
MTg0MFowEwICD+UXDTEzMDkxMDAwMDIwN1owEwICA+gXDTEzMDkwOTE5MDIzOFow
EwICEuEXDTEzMDkxNjE4NTk0OVowEwICCeMXDTEzMDkwOTE5MzcwM1owEwICCeIX
DTEzMDkxNjE3MDQ0N1owEwICJNkXDTEzMDkxNjE0NTEwOFowEwICD94XDTEzMDkx
MDE0NDYyMFowEwICBuAXDTEzMDkwOTE5MTYyNlowEwICA98XDTEzMDkxMDEyMzkw
OVowEwICBtoXDTEzMDkxMDEzMDc0MFowEwICG9EXDTEzMDkxMDE0MDYwN1owEwIC
EtEXDTEzMDkxNjE4NTk1MVowEwICCdMXDTEzMDkwOTE4NTEzOVowEwICDNEXDTEz
MDkwOTIwMzIzNFowEwICJ78XDTEzMDkxNjEzNDIyN1owEwICD8UXDTEzMDkxMDE0
NDYyMlowEwICEsIXDTEzMDkwOTIyNTQ1MlowEwICA8YXDTEzMDkwOTE5MDI0MFow
EwICCcMXDTEzMDkxNzEzMDc1NFowEwICA8QXDTEzMDkxMDEyMzkxMVowEwICJLUX
DTEzMDkxNjE0NTExMFowEwICBroXDTEzMDkxMDEzMjk1N1owEwICCbkXDTEzMDkx
MDE0NTY1NFowEwICCbgXDTEzMDkxNjE3MDQ0OVowEwICG7AXDTEzMDkxMDE0MDYw
OVowEwICD7IXDTEzMDkxMDAwMDIwOFowEwICALQXDTEzMDkxMDAzMDMwN1owEwIC
DLAXDTEzMDkxNjE1NTg0NVowEwICALMXDTEzMDkxMDAzMDMwOVowEwICEq0XDTEz
MDkwOTIyNTQ1NFowEwICBq8XDTEzMDkxMDEzMDc0MlowEwICEqoXDTEzMDkxNjIw
MjgyM1owEwICJ6EXDTEzMDkxNjEzNDIyOVowEwICCaYXDTEzMDkwOTE4NTE0MFow
EwICD54XDTEzMDkxMDEzNDEwNFowEwICCZwXDTEzMDkxNzEzMDc1NlowEwICCZsX
DTEzMDkwOTE5MzcwNVowEwICEpYXDTEzMDkxNjIwMjgyNVowEwICGJQXDTEzMDkx
NzEyNTEwNlowEwICBpgXDTEzMDkxMDEzMjk1OVowEwICDJYXDTEzMDkwOTIwMzIz
NVowEwICGJEXDTEzMDkxNzEyNTEwOFowEwICCZQXDTEzMDkxMDE0NTY1NlowEwIC
AJYXDTEzMDkxMDA2MjkwOVowEwICDI8XDTEzMDkxNjE1NTg0NlowEwICAJIXDTEz
MDkxMDA2MjkxMVowEwICEowXDTEzMDkxNzE4NTcyMlowEwICA44XDTEzMDkxNjE2
NTQxNVowEwICD4kXDTEzMDkxMDEzNDEwNlowEwICJ4EXDTEzMDkxNjE1MzgzN1ow
EwICEoEXDTEzMDkxNzE4NTcyM1owEwICG3sXDTEzMDkxMDE0MzUyM1owEwICA3wX
DTEzMDkxNjE2NTQxNlowEwICCXkXDTEzMDkwOTE4NDcwNVowEwICD28XDTEzMDkx
MDExNDMyN1owEwICIWkXDTEzMDkxMDE0MDcwOFowEwICA3IXDTEzMDkwOTE4NDAw
N1owEwICFWoXDTEzMDkxNzAwNTM1MlowEwICBmsXDTEzMDkwOTIwMTczNVowEwIC
BmoXDTEzMDkxNjE0MTAzNFowEwICGGQXDTEzMDkxMDA5NTA0NFowEwICA2oXDTEz
MDkwOTE4NDAwOVowEwICBmkXDTEzMDkxMDEzMDIyMVowEwICFWQXDTEzMDkxNzAw
NTM1NVowEwICGGEXDTEzMDkxMDA5NTA0MVowEwICD2AXDTEzMDkxMDExNDMyOVow
EwICJ1cXDTEzMDkxNjE1MzgzOVowEgIBYhcNMTMwOTE2MDE1MTIwWjASAgFfFw0x
MzA5MTYwMTUxMjJaMBMCAglcFw0xMzA5MDkxOTE5MDBaMBMCAhtUFw0xMzA5MTcx
MjM3NDRaMBMCAh5TFw0xMzA5MTAxMzU4NTVaMBMCAgxVFw0xMzA5MTYxODAwNTda
MBMCAhtQFw0xMzA5MTAxNDM1MjVaMBMCAgZMFw0xMzA5MTAxMzAyMjNaMBMCAhJH
Fw0xMzA5MDkyMDU0MzBaMBMCAiFCFw0xMzA5MTAxNDA3MTBaMBMCAgNKFw0xMzA5
MDkyMTU4MzhaMBMCAhJAFw0xMzA5MDkyMDU0MzFaMBMCAiE6Fw0xMzA5MTAxNDMw
NDJaMBMCAhU+Fw0xMzA5MTAwMTQ1MzdaMBMCAgxAFw0xMzA5MTcxMzQ4MzRaMBMC
AhU7Fw0xMzA5MTAwMTQ1MzlaMBMCAgk+Fw0xMzA5MDkxODQ3MDdaMBMCAgNAFw0x
MzA5MDkyMTU4NDBaMBMCAgY+Fw0xMzA5MTYxNDEyMzVaMBMCAhI5Fw0xMzA5MTYx
OTI1MzFaMBMCAhsyFw0xMzA5MTcxMjQyNTdaMBMCAgk1Fw0xMzA5MDkxOTE5MDJa
MBMCAgY0Fw0xMzA5MDkyMDE3MzZaMBMCAgMzFw0xMzA5MTYxNzI3NDZaMBICATQX
DTEzMDkwOTAwMzQ0N1owEwICHioXDTEzMDkxNzEzMzAzMlowEgIBMxcNMTMwOTA5
MDAzNDQ5WjATAgIhJhcNMTMwOTEwMTQzMDQ0WjATAgIkJBcNMTMwOTE2MTg1ODM5
WjATAgIDLBcNMTMwOTE2MTcyNzQ4WjATAgISJhcNMTMwOTE2MTkyNTMzWjASAgEq
Fw0xMzA5MDMxODExMTBaMBICASkXDTEzMDkwMzE4MTExM1owEgIBKBcNMTMwODMw
MTkzNDEwWjASAgElFw0xMzA4MzAxNTUxMjZaMBMCAicXFw0xMzA5MTYxMjIwMjRa
MBMCAh4aFw0xMzA5MTAxMzU4NTdaMBICASQXDTEzMDgzMDE1NTEyOVowEgIBIRcN
MTMwODMwMTUxOTA4WjASAgEgFw0xMzA4MzAxNTE5MTFaMBMCAgwaFw0xMzA5MTAx
MzQzNDBaMBMCAhIPFw0xMzA5MTAxNDM4MjlaMBMCAgwRFw0xMzA5MTcxMzQ4MzZa
MBMCAiQIFw0xMzA5MTYxMTUyMzdaMBMCAhIHFw0xMzA5MDkyMzA2NDhaMBMCAgwB
Fw0xMzA5MTYxODAwNTlaoDAwLjAfBgNVHSMEGDAWgBQvypNTA6xvdfV2+r7+juoQ
i7fnkDALBgNVHRQEBAICAiowDQYJKoZIhvcNAQEFBQADggEBAJi3Ze+5x2FBHmgK
wjJiMMpiwkr2UW67/bx9RpraYG9EV3JWVVbJECFegUAXYkiv1YP4WHIukX1efEI0
4ju+o3t3UGBI0pU/J5rbg4i5aUsnYBKRGZiRDxiSIlqrWlHfvF5pyGNPhLC+bzi8
iujjkHj5LunyH40HFFPbM88Q3PP7sPEBO/w26LqqWKBo/bqqKIRlaXgc4U4CaPKK
QONEyC21ixAF9Vqdod4HmAxdRRfZ30WChTRGP7hyVGt2z1AEK4glSkyJrMDa0iYJ
ALrF3/75ZRdJo2vMZbxDdxRfYSZWeZLZV0oj4stdgjCy2xYjT/xBgHO5a9CMAimZ
OYmeJRw=
-----END X509 CRL-----
"""

class DBSetupBerkeleyDB(CommonDataForTest):
    db_prefix = ''
    sqlite = False
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        db_spec = self.db_prefix + self.dir
        self.pwfile = os.path.join(self.dir, 'pwfile')
        with file(self.pwfile, 'w') as f:
            print >> f, 'internal:ridiculous password'
            print >> f, 'NSS Certificate DB:ridiculous password'
            print >> f, 'NSS FIPS 140-2 Certificate DB:ridiculous password'
        dashn = Popen(('certutil', '-N', '-d', db_spec, '-f', self.pwfile),
                      stdin=PIPE, stdout=PIPE, stderr=PIPE)
        out, err = dashn.communicate()
        if dashn.returncode != 0:
            raise Exception('Test NSS database creation failed',
                    dashn.returncode, out, err)
        for nick, cert in self.certs.items():
            dasha = Popen(('certutil', '-A', '-d', db_spec, '-f',
                self.pwfile, '-n', nick, '-t', 'CT,C,C'),
                stdin=PIPE, stdout=PIPE, stderr=PIPE)
            out, err = dasha.communicate(cert)
            if dasha.returncode != 0:
                raise Exception('Test NSS certificate add failed',
                        nick, dasha.returncode, out, err)
        self.db = NSSDB(self.dir, self.pwfile, self.sqlite)

    def tearDown(self):
        shutil.rmtree(self.dir)

class DBSetupSqliteDB(DBSetupBerkeleyDB):
    db_prefix = 'sql:'
    sqlite = True

class CACertTests(object):
    def testListCerts(self):
        self.assertEqual(set(self.db.certNicknames()),
                set(self.certs.keys()))

    def testFetchAbsentCRL(self):
        ca32 = CACert(self.db, 'DoD-Root2-CA32')
        crl32 = CRL(self.db, ca32)
        self.assertEqual(tuple(self.db.crlNicknames()), ())
        crl32.fetchIfNecessary()
        self.assertEqual(tuple(self.db.crlNicknames()),
                ('DoD-Root2-CA32',))

    def testCACertDN(self):
        ca32 = CACert(self.db, 'DoD-Root2-CA32')
        self.assertEqual(ca32.dn, ('CN=DOD CA-32', 'OU=PKI', 'OU=DoD',
            'O=U.S. Government', 'C=US'))

    def testCACertCN(self):
        ca32 = CACert(self.db, 'DoD-Root2-CA32')
        self.assertEqual(ca32.cn, 'DOD CA-32')

    def testCommasDN(self):
        commas = CACert(self.db, 'commasInName')
        self.assertEqual(commas.dn, ('CN="Bletch, Quux, Zart"',
            'OU="Foo, Bar, Baz"', 'O="Goo, Bar, Baz"', 'L=fi', 'ST=gb',
            'C=us'))

    def testCommasAndSpacesDN(self):
        comspace = CACert(self.db, 'commasAndSpaces')
        self.assertEqual(comspace.dn, ('CN="Bletch, Quux, Zart"',
            'OU="Foo, Bar, Baz"', 'O="Goo, Bar,     Baz"', 'L=fi',
            'ST=gb', 'C=us'))

class TestCACertBerkeley(CACertTests, DBSetupBerkeleyDB, unittest.TestCase):
    pass
class TestCACertSqlite(CACertTests, DBSetupSqliteDB, unittest.TestCase):
    pass

class WithCRLSetup(object):
    def setUp(self):
        super(WithCRLSetup, self).setUp()
        db_spec = self.db_prefix + self.dir
        for crl in (self.ca32CRL,):
            just_base64 = '\n'.join(crl.split('\n')[1:-2])
            f = file(os.path.join(self.dir, 'crlin'), 'w')
            f.write(base64.b64decode(just_base64))
            f.close()
            dasha = Popen(('crlutil', '-I', '-d', db_spec, '-f',
                self.pwfile, '-a', '-i', os.path.join(self.dir,
                    'crlin')),
                stdin=PIPE, stdout=PIPE, stderr=PIPE)
            out, err = dasha.communicate()
            if dasha.returncode != 0:
                raise Exception('Test NSS CRL add failed',
                        dasha.returncode, out, err)

class WithCRLTests(object):
    def testListCRLs(self):
        self.assertEqual(tuple(self.db.crlNicknames()),
                ('DoD-Root2-CA32',))

    def testCRLDates(self):
        ca = CACert(self.db, 'DoD-Root2-CA32')
        crl = CRL(self.db, ca)
        self.assertEqual(crl._getValidity(),
                (datetime.datetime(2013, 9, 23, 8, 0),
                    datetime.datetime(2013, 9, 30, 17, 0)))

class TestWithCRLBerkeley(WithCRLTests, WithCRLSetup, DBSetupBerkeleyDB, 
                          unittest.TestCase):
    pass
class TestWithCRLSqlite(WithCRLTests, WithCRLSetup, DBSetupSqliteDB, 
                          unittest.TestCase):
    pass

if __name__ == '__main__':
    unittest.main()


