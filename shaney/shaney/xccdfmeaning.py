#!/usr/bin/python2.6
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
import xml.etree.ElementTree as ET
from xml.parsers.expat import ExpatError
import sys
import re
import logging

# xml namespace, as seen in ElementTree
CDF = '{http://checklists.nist.gov/xccdf/1.1}'

class XCCDFMeaning(object):
    """Parse an XCCDF and get meaningful facts out of it."""

    def __init__(self, xccdf_filename, profile_id):
        self.filename = xccdf_filename
        self.profile_id = profile_id
        self.et = ET.parse(xccdf_filename)

    def selected_rule_groups(self):
        all_profiles = self.et.findall(CDF+'Profile')
        the_profile = [p for p in all_profiles if p.get('id') == self.profile_id][0]
        selects = the_profile.findall(CDF+'select')
        selected_ids = [s.get('idref') for s in selects]
        allgroups = self.et.findall(CDF+'Group')
        selgrouptags = [g for g in allgroups if g.get('id') in selected_ids]
        return [XCCDFMRuleGroup(self, g) for g in selgrouptags]

    def pdi_to_iacs_map(self):
        rv = {}
        for g in self.selected_rule_groups():
            for r in g.rules():
                # the version tag inside the rule contains the Potential
                # Discrepancy Identifier with greater reliability than
                # the title tag inside the rule group
                rv[r.version] = g.ia_controls
        return rv

def _written_alone_regex(what):
    """Make a regex that finds 'what' written alone.

    'Written alone' means that on the left side of 'what' is either
    whitespace or the beginning of a line, and on the right side is
    either whitespace or the end of a line.

    'what' should not contain any characters that are special when
    written in regular expressions; if it does, use re.escape on it
    before passing it to this function.
    """
    return r'(?:^|(?<=\s))' + what + r'(?:(?=\s)|$)'

def fix_unescaped(xml, log_function):
    """Try to fix an XML string that may have some parse errors in it.

    In spring 2013, XCCDF files we got from DISA contain description
    tags, which, instead of containing XML elements that use a different
    XML namespace, or containing CDATA blocks with XML inside, contain
    XML escaped using entity references (&lt; &gt; mostly). But entity
    references within the escaped XML are not escaped: to write an
    ampersand in escaped XML one should write &amp;amp; but the escaped
    XML contains only &amp;. So the contents of the description element
    as obtained from the XML parser sometimes contain characters & < >
    not intended as XML syntax, but used to mean "and," "less than," and
    "greater than." If the description element contents are then parsed
    as XML, these are syntax errors.

    Because the XCCDF files are official documents, they don't change
    quickly, and it's more trouble than it's worth to try to keep our
    own patched copies. So we kluge them instead; but if there appear to
    be no parse errors as described above, we don't want to change
    anything, and if there are parse errors, we warn the user.
    """
    result = xml
    problems = (('&', '&amp;', 'ampersands'),
                ('<', '&lt;',  'left angle brackets'),
                ('>', '&gt;',  'right angle brackets'))
    for unentitied, entitied, name in problems:
        if re.findall(_written_alone_regex(unentitied), result):
            log_function('Found unescaped %s; attempting to work around'
                    % name)
            result = re.sub(_written_alone_regex(unentitied), entitied,
                    result)
    return result


class XCCDFMRuleGroup(object):
    def __init__(self, parent, et_element):
        log = logging.getLogger('XCCDFMRuleGroup')
        self.parent = parent
        self.elt = et_element
        self.title = self.elt.findtext(CDF+'title')
        self.id = self.elt.get('id')
        description_element = self.elt.find(CDF+'Rule/'+CDF+'description')
        try:
            xml = (u"<?xml version='1.0' encoding='UTF-8'?><x>" +
                description_element.text + u"</x>").encode('UTF-8')
            ok_xml = fix_unescaped(xml, lambda message:
                    log.warning('in file %s, '
                        'in rule group with id %s, %s',
                        self.parent.filename, self.id, message))
            self.description_tree = ET.fromstring(ok_xml)
            iac_tag = self.description_tree.find('IAControls')
            if hasattr(iac_tag, 'text') and iac_tag.text is not None:
                self.ia_controls = tuple(x.strip() for x in
                        iac_tag.text.split(','))
            else:
                log.debug('No text found in IAControls tag ' \
                        'under rule group with id %s' % self.id)
                self.ia_controls = ()
        except ExpatError, e:
            # We just won't know the ia_controls. Maybe the user of this
            # class doesn't need them.
            log.error(('in file %s, '
                       'in rule group with id %s, '
                       'error parsing contents of description element; '
                       'xml was %r'),
                       self.parent.filename, self.id, xml)

    def rules(self):
        for r in self.elt.findall(CDF+'Rule'):
            yield XCCDFMRule(self.parent, r)

class XCCDFMRule(object):
    def __init__(self, grandparent, et_element):
        self.grandparent = grandparent
        self.elt = et_element
        self.id = self.elt.get('id')
        self.severity = self.elt.get('severity')
        self.title = self.elt.findtext(CDF+'title')
        self.version = self.elt.findtext(CDF+'version')
