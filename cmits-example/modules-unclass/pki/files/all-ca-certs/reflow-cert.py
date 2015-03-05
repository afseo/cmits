import re
import unittest
from cStringIO import StringIO
import getopt
import sys

def reflow_cert(iterable, width):
    in_cert = False
    for line in iterable:
        if re.match('^-+BEGIN [A-Z ]+-+$', line):
            in_cert = True
            cert_lines = []
            yield line
        elif re.match('^-+END [A-Z ]+-+$', line):
            in_cert = False
            # regurgitate reflowed cert
            cert = ''.join(cert_lines)
            flowed_cert_lines = []
            while cert != '':
                flowed_cert_lines.append(cert[0:width])
                cert = cert[width:]
            for x in flowed_cert_lines:
                yield x + '\n'
            # now put out the END line
            yield line
        elif in_cert:
            cert_lines.append(line.strip())
        else:
            yield line
        

class TestReflowCert(unittest.TestCase):
    def testLongLine(self):
        """Certs with long lines, when reflowed, have shorter lines."""
        cert = """\
---BEGIN CERTIFICATE---
weofijwf90239fhj20vmqf84fums9p8vhsmvp9mhap98w4ctapwmt8cjamwpt\
48hmp349tc8ha3mp4t9c8hamtp948chamw9pt4cahw8mt4p98chm34p98cham\
p948chma3p498chma34p9c8hm3ap9f8ch4m3p98
---END CERTIFICATE---
"""
        self.assertEqual(''.join(reflow_cert(StringIO(cert), 32)), """\
---BEGIN CERTIFICATE---
weofijwf90239fhj20vmqf84fums9p8v
hsmvp9mhap98w4ctapwmt8cjamwpt48h
mp349tc8ha3mp4t9c8hamtp948chamw9
pt4cahw8mt4p98chm34p98champ948ch
ma3p498chma34p9c8hm3ap9f8ch4m3p9
8
---END CERTIFICATE---
""")

    def testPreamble(self):
        """Reflowing a cert leaves non-certificate parts alone."""
        cert = """\
A big long description, longer than 32 characters.
---BEGIN CERTIFICATE---
weofijwf90239fhj20vmqf84fums9p8vhsmvp9mhap98w4ctapwmt8cjamwpt\
48hmp349tc8ha3mp4t9c8hamtp948chamw9pt4cahw8mt4p98chm34p98cham\
p948chma3p498chma34p9c8hm3ap9f8ch4m3p98
---END CERTIFICATE---
A big long postamble, longer than 32 characters.
"""
        self.assertEqual(''.join(reflow_cert(StringIO(cert), 32)), """\
A big long description, longer than 32 characters.
---BEGIN CERTIFICATE---
weofijwf90239fhj20vmqf84fums9p8v
hsmvp9mhap98w4ctapwmt8cjamwpt48h
mp349tc8ha3mp4t9c8hamtp948chamw9
pt4cahw8mt4p98chm34p98champ948ch
ma3p498chma34p9c8hm3ap9f8ch4m3p9
8
---END CERTIFICATE---
A big long postamble, longer than 32 characters.
""")

    def testCertChain(self):
        """Reflowing works for files containing multiple certs."""
        cert = """\
A big long description, longer than 32 characters.
---BEGIN CERTIFICATE---
weofijwf90239fhj20vmqf84fums9p8vhsmvp9mhap98w4ctapwmt8cjamwpt\
48hmp349tc8ha3mp4t9c8hamtp948chamw9pt4cahw8mt4p98chm34p98cham\
p948chma3p498chma34p9c8hm3ap9f8ch4m3p98
---END CERTIFICATE---
A big long postamble, longer than 32 characters.
Some other stuff.
---BEGIN CERTIFICATE---
WEOFIJWF90239FHJ20VMQF84FUMS9P8VHSMVP9MHAP98W4CTAPWMT8CJAMWPT\
48HMP349TC8HA3MP4T9C8HAMTP948CHAMW9PT4CAHW8MT4P98CHM34P98CHAM\
P948CHMA3P498CHMA34P9C8HM3AP9F8CH4M3P98
---END CERTIFICATE---
"""
        self.assertEqual(''.join(reflow_cert(StringIO(cert), 32)), """\
A big long description, longer than 32 characters.
---BEGIN CERTIFICATE---
weofijwf90239fhj20vmqf84fums9p8v
hsmvp9mhap98w4ctapwmt8cjamwpt48h
mp349tc8ha3mp4t9c8hamtp948chamw9
pt4cahw8mt4p98chm34p98champ948ch
ma3p498chma34p9c8hm3ap9f8ch4m3p9
8
---END CERTIFICATE---
A big long postamble, longer than 32 characters.
Some other stuff.
---BEGIN CERTIFICATE---
WEOFIJWF90239FHJ20VMQF84FUMS9P8V
HSMVP9MHAP98W4CTAPWMT8CJAMWPT48H
MP349TC8HA3MP4T9C8HAMTP948CHAMW9
PT4CAHW8MT4P98CHM34P98CHAMP948CH
MA3P498CHMA34P9C8HM3AP9F8CH4M3P9
8
---END CERTIFICATE---
""")

def usage(progname):
    print >> sys.stderr, """\
Usage: %s [--help] [--test] [-w n] certificate.pem

--help: Show this message.
--test: Run unit tests instead of reflowing certificates.
 -w n : Reflow certificate to a line width of n characters.

Input file must be a PEM-encoded object. Lines which are part of the
object are reflowed; other lines (e.g. descriptions) are not.

Output is stdout.
""" % progname

if __name__ == '__main__':
    try:
        ovs, remaining = getopt.getopt(sys.argv[1:], 'w:',['test', 'help'])
    except getopt.GetoptError, e:
        print >> sys.stderr, e
        usage(sys.argv[0])
        sys.exit(1)
    testInstead = False
    width = 64
    for o, v in ovs:
        if o == '--test':
            testInstead = True
        elif o == '-w':
            width = int(v)
        elif o == '--help':
            usage(sys.argv[0])
            sys.exit(1)
    if testInstead:
        # Forget about the args we've already parsed; they won't be
        # useful to unittest. Whatever args unittest could have used, we
        # would not have recognized above, 
        sys.argv = sys.argv[0:1]
        unittest.main()
    if len(remaining) != 1:
        # no files to process!
        print >> sys.stderr, "no filename given"
        usage(sys.argv[0])
        sys.exit(1)
    else:
        for line in reflow_cert(file(remaining[0]), width):
            sys.stdout.write(line)
