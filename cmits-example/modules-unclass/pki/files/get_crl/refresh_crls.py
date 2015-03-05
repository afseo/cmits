#!/usr/bin/python
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
# Read some CA certificates. Fetch their corresponding CRLs, using HTTP
# or LDAP.
#
# Works with Python 2.4 or later.

import os
from sys import stderr
import ldap
import sys
import base64
from subprocess import Popen, PIPE
from time import strptime, time, gmtime
from datetime import datetime, timedelta
import glob
from urllib import quote, unquote
from urllib2 import urlopen, HTTPError

class OpenSSLExitedWithError(Exception): pass
class UnexpectedOpenSSLResponse(Exception): pass

class CACertParseError(Exception): pass

class CRLFetchError(Exception): pass
class NoCRLDistributionPoints(CRLFetchError): pass
class DontKnowHowToFetch(CRLFetchError): pass
class AllFetchAttemptsFailed(CRLFetchError): pass
class UnexpectedMimeType(CRLFetchError): pass
class NoSuchObjectOnServer(CRLFetchError): pass
class UnexpectedLDAPResponse(CRLFetchError): pass
class ServerDown(CRLFetchError): pass
class CACertExpired(CRLFetchError): pass

# Installation and upgrade are easier if we just depend on the OpenSSL
# binary instead of requiring non-stock Python libraries such as pyasn1
def openssl(*args):
    cmdline = ('openssl',) + args
    p = Popen(cmdline, stdin=None, stdout=PIPE, stderr=PIPE)
    output, errors = p.communicate()
    # apparently, crl -noout makes openssl return with exitcode 1
    # apparently, that's fixed in RHEL6
    if p.returncode != 0:
        raise OpenSSLExitedWithError('command: %r' % (cmdline,),
                'output: %r' % output, 'errors: %r' % errors,
                'exit code: %d' % p.returncode)
    for line in output.strip().split('\n'):
        yield line

openssl_crl = openssl

class CACert(object):
    def __init__(self, filename):
        self.filename = filename
        self.dn = None 
        self.cn = None
        for thisline in openssl('x509', '-subject', '-noout', '-in', filename):
            # [1:]: the dn starts with '/'. get rid of the empty first
            # element after splitting
            try:
                self.dn = thisline[len('subject='):].strip().split('/')[1:]
            except Exception, e:
                raise CACertParseError(e)
        try:
            self.cn = [x[len('cn='):] for x in self.dn if
                    x.lower().startswith('cn=')][0]
        except IndexError:
            raise CACertParseError('missing Common Name')
        notbefore = None
        notafter = None
        for thisline in openssl('x509', '-dates', '-noout', '-in', filename):
            if thisline.startswith('notBefore'):
                nbs = thisline[len('notBefore='):].strip()
                notbefore = strptime(nbs, "%b %d %H:%M:%S %Y %Z")
            elif thisline.startswith('notAfter'):
                nas = thisline[len('notAfter='):].strip()
                notafter  = strptime(nas, "%b %d %H:%M:%S %Y %Z")
        if notbefore is not None and notafter is not None:
            self.validityPeriod = (notbefore, notafter)

    def __repr__(self):
        return '<CACert with subject %s>' % ('/' + '/'.join(self.dn))

    def __str__(self):
        return '/' + '/'.join(self.dn)

    def getSources(self):
        # I thought I could use the X509v3 extension
        # cRLDistributionPoints to find out where to get CRLs for a
        # given CA, making the CACert object the authority on where to
        # get CRLs. But it appears that, say, for CA-22, that extension
        # indicates where to get the CRL which may say, "The CA-22
        # certificate is revoked" -- not where to get the CRL which may
        # say, "These certificates, signed by CA-22, are revoked."
        #
        # So, nothing in the CA certificate will help us find the
        # corresponding CRL, and we have to know a place where we can
        # get it. We don't know that for all certificates, so we'll have
        # to make sure a CA cert is familiar before claiming to know CRL
        # sources corresponding to it. Let's find out what we've got.
        # - maybe the DN starts from the most general. but we need it to
        # be the other way around.
        dnPieces = list(self.dn)
        if not dnPieces[0].lower().startswith('cn'):
            dnPieces.reverse()
        if [x.lower() for x in dnPieces[-3:]] in \
                [['ou=dod', 'o=u.s. government', 'c=us'],
                 ['ou=eca', 'o=u.s. government', 'c=us']]:
            escaped_cn = quote(self.cn)
            http = ( 'http://crl.gds.disa.mil/getcrl?' + escaped_cn,
                     'http://crl.disa.mil/getcrl?' + escaped_cn )
            dn = ', '.join(dnPieces)
            escaped_dn = quote(dn)
            return http
        else:
            # we know no sources for the CRL.
            return []

    def isValid(self):
        if self.validityPeriod is None:
            return True
        else:
            now = gmtime()
            validityStarts, validityEnds = self.validityPeriod
            return ((now > validityStarts) and (now < validityEnds))

class CRL(object):
    mime_type = 'application/pkix-crl'

    def __init__(self, cacert, dir, getLDAPConnection):
        self.cacert = cacert
        stem = '.'.join(os.path.basename(cacert.filename).split('.')[:-1])
        self.filename = os.path.join(dir, stem + '.crl')
        self.getLDAPConnection = getLDAPConnection

    def isExpired(self):
        if not os.path.exists(self.filename):
            return True
        g = openssl_crl('crl', '-in', self.filename, '-noout',
                '-nextupdate')
        firstLine = g.next()
        # parse output
        try:
            expireDateString = firstLine.split('=')[1].strip()
            expireTuple = strptime(expireDateString, '%b %d %H:%M:%S %Y %Z')
            # The added (0,) is the number of microseconds.
            expireDatetime = datetime(*(expireTuple[0:6]+(0,)))
            tomorrow = datetime.utcnow() + timedelta(1)
            return tomorrow > expireDatetime
        except:
            raise UnexpectedOpenSSLResponse(firstLine)

    def fetchIfNecessary(self):
        if self.isExpired():
            print >> stderr, "Fetching CRL for: %s" % self.cacert
            a = time()
            newCRLData = pemEncode(self.fetch())
            # write out file, then atomically move into place
            newName = self.filename + '.new'
            newFile = file(newName, 'w')
            newFile.write(newCRLData)
            newFile.close()
            os.rename(newName, self.filename)
            b = time()
            elapsed = int(b-a)
            print >> stderr, "Fetch complete after %d seconds." % elapsed

    def fetch_ldap(self, url):
        # we expect url to be something like 'ldap://server/dn?bla;bla'.
        # we want 'ldap://server', 'dn' and 'bla;bla'.
        # the split by slashes would look like ['ldap:', '', 'server',
        # 'dn?bla;bla'].
        serverURL = '/'.join(url.split('/')[:3])
        dn, attribute = '/'.join(url.split('/')[3:]).split('?')
        # The URL has all funny characters escaped. We need to pass
        # those as-is
        dn = unquote(dn)
        
        l = self.getLDAPConnection(serverURL)
        try:
            result = l.search_s(dn, ldap.SCOPE_SUBTREE,
                    attrlist=[attribute])
        except ldap.NO_SUCH_OBJECT:
            raise NoSuchObjectOnServer(dn, serverURL)
        except ldap.SERVER_DOWN:
            raise ServerDown(serverURL)
        # the CRL is inside some data structures inside result. if the server
        # returns something empty or unexpected this will raise an exception.
        try:
            crl = result[0][1][attribute][0]
            return crl
        except:
            raise UnexpectedLDAPResponse(url, result)

    def fetch_http(self, url):
        try:
            u = urlopen(url)
        except HTTPError, e:
            raise CRLFetchError(e)
        t = u.info().type
        if t != self.mime_type:
            raise UnexpectedMimeType(url, t)
        return u.read()

    def fetch(self):
        if not self.cacert.isValid():
            raise CACertExpired(self.cacert)
        urls = list(self.cacert.getSources())
        if len(urls) == 0:
            raise NoCRLDistributionPoints(self.cacert)
        # 'http' comes before 'ldap' alphabetically. take advantage
        urls.sort()
        succeededYet = False
        crl = None
        for url in urls:
            if not succeededYet:
                scheme, dontcare = url.split(':',1)
                try:
                    fetcher = getattr(self, 'fetch_' + scheme)
                except AttributeError:
                    raise DontKnowHowToFetch(url)
                try:
                    print "    using %r" % url
                    crl = fetcher(url)
                    succeededYet = True
                except CRLFetchError, e:
                    print "    exception %s: %s" %\
                            (e.__class__.__name__,
                             str(e))

        if succeededYet:
            return crl
        else:
            raise AllFetchAttemptsFailed(self)

    def __repr__(self):
        return "<CRL for %r>" % self.cacert

    # i don't know why i bothered
    def __str__(self):
        return "CRL for %s" % self.cacert


def pemEncode(binary, objectType = "X509 CRL"):
    """PEM-encode some binary data. binary is the data; objectType is what sort
    of thing it is. For example, a CRL's objectType is "X509 CRL". The
    objectType goes into the -----BEGIN something----- and -----END 
    something----- lines at the beginning and end of the PEM file. Some other
    possible values for objectType are "CERTIFICATE", "CERTIFICATE REQUEST", 
    "RSA PRIVATE KEY", "DSA PRIVATE KEY"."""

    intro = "-----BEGIN %s-----\n" % objectType
    outro = "-----END %s-----\n" % objectType

    content = base64.encodestring(binary)
    return intro + content + outro


class LDAPConnectionPool(object):
    def __init__(self):
        self.pool = {}

    def __call__(self, url):
        if self.pool.has_key(url):
            return self.pool[url]
        else:
            t1 = time()
            l = ldap.initialize(url)
            l.protocol_version = ldap.VERSION3
            # no DN, no password: anonymous
            l.simple_bind_s()
            t2 = time()
            if (t2 - t1) > 10:
                print >> stderr, "Connect to %s took %d seconds" % \
                        (url, t2-t1)
            self.pool[url] = l
            return l

    def close(self):
        for k,v in self.pool.items():
            try:
                v.unbind_s()
            except Exception, e:
                print >> stderr, "While unbinding %s: %r" % (k,e)

def usage():
    prog = sys.argv[0]
    print >> sys.stderr, """\
usage: %(prog)s /dir/with/CA/certs /dir/for/CRLs

Check Certificate Revocation Lists (CRLs) in /dir/for/CRLs, which relate
to the Certification Authorities (CAs) whose CA certs are in
/dir/with/CA/certs. If any are expired, fetch new ones.

CA certs are expected to be files in PEM format whose names end with
'.crt'.

""" % locals()

if __name__ == '__main__':
    if len(sys.argv) != 3:
        usage()
        sys.exit(1)
    caCertDir, destination = sys.argv[1:]
    if not os.path.isdir(caCertDir):
        print >> sys.stderr, \
                "Given CA certificate dir %s is not a directory" % caCertDir
        sys.exit(2)
    if not os.path.isdir(destination):
        print >> sys.stderr, \
                "CRL destination dir %s is not a directory" % destination
        sys.exit(3)
    pool = LDAPConnectionPool()
    for f in glob.glob(os.path.join(caCertDir, '*.crt')):
        if 'Makefile' not in f:
            c = CACert(f)
            r = CRL(c, destination, pool)
            try:
                r.fetchIfNecessary()
            except KeyboardInterrupt:
                raise
            except CRLFetchError, e:
                print "Fetch failed: %s %s" %\
                        (e.__class__.__name__,
                         str(e))
