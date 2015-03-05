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
from refresh_crls import CACert, CRL, openssl
from refresh_crls import CACertExpired
import unittest
from tempfile import mkdtemp
from shutil import rmtree
import os
import time

class HasDir(unittest.TestCase):
    def setUp(self):
        self.dir = mkdtemp(prefix='fetchcrltest')
        self.oldcwd = os.getcwd()
        os.chdir(self.dir)
    def tearDown(self):
        os.chdir(self.oldcwd)
        #rmtree(self.dir)
        pass

class CACertBase(HasDir):
    def makeCert(self, dnElements=('C=US', 'O=Test', 'OU=Test',
            'CN=Flarble'), additionalConfig='',
            additionalSwitches=''):

        cnf = file('cnf', 'w')
        print >> cnf, """
[ req ]
default_bits		= 2048
default_keyfile 	= privkey.pem
distinguished_name	= req_distinguished_name
x509_extensions	= v3_ca	# The extentions to add to the self signed cert
input_password = secret
output_password = secret
days=-1
prompt = no
%s
[ req_distinguished_name ]
%s
[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:true
""" % (additionalConfig, '\n'.join(dnElements))
        cnf.close()
        cert = '\n'.join(openssl('req', '-new', '-x509', '-config', 'cnf',
            *additionalSwitches.split()))
        cert_filename = 'cert'
        cfile = file(cert_filename, 'w')
        print >> cfile, cert
        cfile.close()
        time.sleep(1) # make sure we're after the not-valid-before time
        return cert_filename

class TestCACert(CACertBase):
    def testCN(self):
        c = CACert(self.makeCert())
        self.assertEqual(c.cn, 'Flarble')

    def testValid(self):
        c = CACert(self.makeCert())
        self.assert_(c.isValid())

    def testInvalid(self):
        c = CACert(self.makeCert(additionalSwitches='-days -1'))
        self.assert_(not c.isValid())
        crl = CRL(c, self.dir, None)
        self.assertRaises(CACertExpired, crl.fetch)

    def testDoDCRLSources(self):
        # see req(1), 'DISTINGUISHED NAME ... FORMAT' section, about the
        # 1.OU, 2.OU
        c = CACert(self.makeCert(['C=US', 'O=U.S. Government',
            '1.OU=DoD', '2.OU=PKI', 'CN=Unit Test CA']))
        self.assert_(len(c.getSources()) > 0)

if __name__ == '__main__':
    unittest.main()
