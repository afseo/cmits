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
import re
import sys
import logging
import getopt
from subprocess import Popen, PIPE
from time import time
from datetime import datetime, timedelta
from urllib import quote, unquote
from urllib2 import urlopen, HTTPError
from tempfile import NamedTemporaryFile

class NSSUtilExitedWithError(Exception): pass
class UnexpectedNSSUtilResponse(Exception): pass

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

# We use the NSS utilities because PyNSS doesn't appear to do all this
# stuff.

# This is the format in which certutil outputs validity dates. They
# appear to be in UTC.
NSS_TIME_FORMAT = '%a %b %d %H:%M:%S %Y'


class NSSDB(object):
    def __init__(self, dbdir, pwfile, sqlite):
        self.dbdir = dbdir
        self.pwfile = pwfile
        self.sqlite = sqlite

    def _get_cmdline(self, command, *args):
        if self.sqlite:
            dbspec = 'sql:' + self.dbdir
        else:
            dbspec = self.dbdir
        cmdline = (command, '-f', self.pwfile, '-d', dbspec) + args
        return cmdline

    def _util(self, command, *args):
        p = Popen(self._get_cmdline(command, *args), 
                  stdin=None, stdout=PIPE, stderr=PIPE)
        output, errors = p.communicate()
        if p.returncode != 0:
            raise NSSUtilExitedWithError('command: %r' % (cmdline,),
                    'output: %r' % output, 'errors: %r' % errors,
                    'exit code: %d' % p.returncode)
        for line in output.strip().split('\n'):
            yield line

    def _util_head(self, n, command, *args):
        p = Popen(self._get_cmdline(command, *args),
                  stdin=None, stdout=PIPE, stderr=PIPE)
        # assume stderr will not fill up
        try:
            for lineno in range(n):
                yield p.stdout.next().strip()
        except StopIteration:
            pass
        p.terminate()


    def _certList(self):
        lines = self._util('certutil', '-L')
        # skip header
        for i in range(3):
            lines.next()
        for line in lines:
            words = line.split()
            trustargs = words[-1]
            # certutil does not preserve leading or trailing spaces in
            # cert nicknames when listing them - so we can't, either.
	    # there may be trailing spaces after the trustarg; strip them
            nickname = line.strip()[:-len(trustargs)].strip()
            yield (nickname, tuple(trustargs.split(',')))

    def _crlList(self):
        lines = self._util_head(14, 'crlutil', '-L')
        # skip header
        for i in range(4):
            lines.next()
        for line in lines:
            words = line.split()
            crltype = words[-1]
            # certutil does not preserve leading or trailing spaces in
            # cert nicknames when listing them - so we can't, either
            nickname = line[:-len(crltype)].strip()
            yield (nickname, crltype)

    # in haskell: nicknames = map fst. oh haskell i miss you now
    def certNicknames(self):
        for nickname, trustargs in self._certList():
            yield nickname

    def caCertNicknames(self):
        for nickname, trustargs in self._certList():
            for use in trustargs:
                # C: trusted to issue client certs; T: trusted to issue server
                # certs; c: valid CA; run certutil -H to find out more
                if 'u' not in use:
                    # it's not a user cert; we need a CRL for it
                    yield nickname
                    break

    def crlNicknames(self):
        for nickname, crltype in self._crlList():
            yield nickname


def _splitOnUnquotedCommasGenerator(s):
    # There may be commas in names. NSS utils deal with this by
    # double-quoting the names. So if we split on commas and have a
    # value with an odd number of double quotes in it, it isn't a whole
    # value. Accumulate more.
    value = None
    for x in s.split(','):
        if value is None:
            value = x
            if len(re.findall('"', value)) % 2 == 0:
                yield value
                value = None
        else:
            if len(re.findall('"', value)) % 2 == 0:
                yield value
                value = x
            else:
                value = value + ',' + x
    if value is not None:
        yield value

def splitOnUnquotedCommas(s):
    return list(_splitOnUnquotedCommasGenerator(s))


class CACert(object):

    def __init__(self, nssdb, nickname):
        self.db = nssdb
        self.nickname = nickname
        self.dn = self._getDn()
        self.cn = [x for x in self.dn if
                x.lower().startswith('cn=')][0][len('cn='):]

    def __repr__(self):
        return self.nickname

    def __str__(self):
        return ','.join(self.dn)

    def _getDn(self):
        lines = self.db._util('certutil', '-L', '-n', self.nickname)
        continuing = False
        column = 0
        value = ""
        s = 'Subject: '
        for line in lines:
            if continuing:
                value += line[column:]
                if line.endswith('"'):
                    break
            else:
                try:
                    column = line.index(s) + 4
                    value = line[line.index(s) + len(s):]
                    if line.endswith('"'):
                        break
                    else:
                        continuing = True
                except ValueError:
                    # substring not found
                    pass
        unquoted = value[1:-1]
        # there may be url encoding in there; we are not presently
        # dealing with it.
        return tuple(splitOnUnquotedCommas(unquoted))

    # returns a pair of UTC datetimes.
    def _getValidity(self):
        lines = self.db._util('certutil', '-L', '-n', self.nickname)
        expects = ['Validity:', 'Not Before: ', 'Not After : ']
        thisone = 0
        notbefore = None
        notafter = None
        for line in lines:
            s = line.strip()
            if s.startswith(expects[thisone]):
                value = s[len(expects[thisone]):]
                if thisone == 1:
                    notbefore = datetime.strptime(value,
                            NSS_TIME_FORMAT)
                elif thisone == 2:
                    notafter = datetime.strptime(value,
                            NSS_TIME_FORMAT)
                    break
                thisone += 1
        return (notbefore, notafter)

    def isValid(self):
        notbefore, notafter = self._getValidity()
        now = datetime.utcnow()
        return ((now >= notbefore) and (now <= notafter))

    def getCRLSources(self):
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
        elif [x.lower() for x in dnPieces[-3:]] in \
                [['ou=dod', 'o=gov', 'c=au']]:
            escaped_cn = quote(self.cn)
            http = ( 'http://www.defence.gov.au/pki/crl/%s.crl' % escaped_cn, )
            return http
        else:
            # we know no sources for the CRL.
            return []


class CRL(object):
    mime_type = 'application/pkix-crl'

    def __init__(self, db, cacert):
        self.db = db
        self.cacert = cacert
        self.log = logging.getLogger(repr(self))

    def _getValidity(self):
        lines = self.db._util_head(10, 'crlutil', '-L', '-n', self.cacert.nickname)
        expects = ['This Update: ', 'Next Update: ']
        thisupdate = None
        nextupdate = None
        for line in lines:
            s = line.strip()
            if s.startswith('This Update: '):
                thisupdate = datetime.strptime(s[len('This Update: '):],
                        NSS_TIME_FORMAT)
            if s.startswith('Next Update: '):
                nextupdate = datetime.strptime(s[len('Next Update: '):],
                        NSS_TIME_FORMAT)
        return (thisupdate, nextupdate)

    def isExpired(self):
        if self.cacert.nickname not in self.db.crlNicknames():
            return True
        lastupdate, nextupdate = self._getValidity()
        tomorrow = datetime.utcnow() + timedelta(1)
        return tomorrow > nextupdate

    def fetchIfNecessary(self):
        if self.isExpired():
            self.log.info('fetching')
            a = time()
            newCRLData = self.fetch()
            # write out file, then atomically move into place
            newFile = NamedTemporaryFile()
            newName = newFile.name
            newFile.write(newCRLData)
            newFile.flush()
            newFile.seek(0)
            # list: we have to use up the output to make the generator's
            # code happen
            list(self.db._util('crlutil', '-I', '-i', newFile.name))
            newFile.close()
            b = time()
            elapsed = int(b-a)
            self.log.info('complete after %d seconds', elapsed)

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
        urls = list(self.cacert.getCRLSources())
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
                    self.log.info('using %r', url)
                    crl = fetcher(url)
                    succeededYet = True
                except CRLFetchError, e:
                    self.log.exception('while fetching,')
        if succeededYet:
            return crl
        else:
            raise AllFetchAttemptsFailed(self)

    def __repr__(self):
        return "CRL for %r" % self.cacert

    # i don't know why i bothered
    def __str__(self):
        return "CRL for %s" % self.cacert

def usage():
    prog = sys.argv[0]
    print >> sys.stderr, """\
usage: %(prog)s [-v] [-B] /nss/database/directory /path/to/passwordfile

Check Certificate Revocation Lists (CRLs) in the given NSS database,
which relate to the Certification Authorities (CAs) whose CA certs are
in the database. If any are expired or missing, fetch new ones. The
password file contains any passwords necessary to open the database, in
the form module:password. Modules of interest (don't type the quotes)
are "internal", "NSS Certificate DB", and "NSS FIPS 140-2 Certificate
DB".

If -v is given, non-error fetching activity is shown.

The new format of NSS database (cert9.db, key4.db, SQLite) is used by
default. If -B is given, the old format (cert8.db, key3.db, Berkeley
DB) is used.

""" % locals()

if __name__ == '__main__':
    ovpairs, rest = getopt.getopt(sys.argv[1:], 'vB')
    loglevel = logging.WARNING
    sqlite = True
    for o, v in ovpairs:
        if o == '-v':
            loglevel = logging.DEBUG
        if o == '-B':
            sqlite = False
    if len(rest) != 2:
        usage()
        sys.exit(1)
    dbdir, pwfile = rest
    logging.basicConfig(stream=sys.stderr, level=loglevel,
            format='%(name)s: %(message)s')
    toplog = logging.getLogger('main')
    db = NSSDB(dbdir, pwfile, sqlite)
    caCerts = [CACert(db, nick) for nick in db.caCertNicknames()]
    crls = [CRL(db, ca) for ca in caCerts]
    for crl in crls:
        try:
            crl.fetchIfNecessary()
        except KeyboardInterrupt:
            toplog.error("KeyboardInterrupt: quitting.")
            sys.exit(2)
        except CACertExpired, e:
            toplog.error('CA cert %s has expired', str(crl.cacert))
        except CRLFetchError, e:
            toplog.exception('Fetch failed')
        except Exception, e:
            # "Unexpected error."
            e.args = ('While fetching', crl,) + e.args
            raise
