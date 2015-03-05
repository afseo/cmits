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
import logging
import re
from shaney.generators.match import tagged_match_or_drop
from shaney.xccdfmeaning import XCCDFMeaning


def find_requirement_tag(data_tag, requirement_tag_name):
    log = logging.getLogger('frt %s %s' % (data_tag,
        requirement_tag_name))
    @tagged_match_or_drop(data_tag,
            r'(\\' + 
                re.escape(requirement_tag_name) +
                r')(({[ a-zA-Z0-9,-]+})+)')
    def find_req_tag(matches, value, target):
        """Find \implements tag in comments; emit each requirement in it.

        Input: tuples of these forms:
            (data_tag, 'bla bla \requirement_tag_name{document}{req1,req2}')
            (data_tag, string not containing the named requirement_tag)
            (any other string, anything)
        Output: tuples of these forms:
            (requirement_tag_name, 'document', 'req1', False)
            (any other string, anything)
        Passes messages through.

        Output tuples have the same number of parameters as the
        requirement tag did. For example, \implements tags have two
        parameters, the document and the comma-separated list of
        requirements; but \doneby tags have three parameters, who does
        the required things, the requiring document and the
        comma-separated list of requirements. Accordingly output tuples
        beginning with 'implements' will have four members, but output
        tuples beginning with 'doneby' will have five. Unless the
        requirement tag is written wrong.
        """
        for m in matches:
            tag = m[0]
            params = m[1]
            params = params.strip('{}').split('}{')
            # the requirements are always the last parameter
            requirements = tuple(params[-1].split(','))
            # strip them off
            params = tuple(params[:-1])
            target.send((requirement_tag_name,) + params + (requirements, False))
    return find_req_tag


find_implements = find_requirement_tag('toplevel', 'implements')
find_doneby     = find_requirement_tag('toplevel', 'doneby')
find_bydefault  = find_requirement_tag('toplevel', 'bydefault')

requirement_tags_to_interpret = ('implements', 'doneby', 'bydefault')

class PDINotFoundInXCCDF(Exception):
    pass

def find_ia_control_tags(document_name, meaning, pertinent_ia_controls):
    """Derive IA controls implemented by means of smaller requirements.
    
    DISA STIGs and SRGs written in XCCDF (so far) have, for each
    requirement, one or more IA controls to which it's related. So
    wherever we say that we implement that STIG requirement, in that
    place we also implement part of an IA control, and we want to say
    that in our output.

    Input: tuples of these forms:
        (requirement tag, zero or more things, document_name,
                tuple of requirement names, False) -- for example --
        ('implements', 'unixsrg', ('GEN000020', 'GEN000030'), False)
        ('doneby', 'admins', 'unixsrg', (GEN000454',), False)
        etc.
        (any other string, anything)
    Output: tuples of these forms:
        (requirement tag, zero or more things, 'iacontrol', tuple of IA
                control identifiers, True) -- for example --
        ('implements', 'iacontrol', ('ECLP-1',), True)
        ('doneby', 'admins', 'iacontrol', ('ECAR-1', 'ECRG-1'), True)
        etc.
    Does not pass messages through.

    This coroutine only listens for tags listed in the
    requirement_tags_to_interpret listed in this module.
    """
    map = meaning.pdi_to_iacs_map()
    log = logging.getLogger('find_ia_control_tags')
    # this is for logging errors only.
    last_new_file = '[unknown]'
    def coro(target):
        while True:
            value = (yield)
            if value[0] == 'new_file':
                last_new_file = value[1]
            elif value[0] in requirement_tags_to_interpret:
                requirement_tag = value[0]
                derived = value[-1]
                if not derived:
                    document = value[-3]
                    reqs = value[-2]
                    other = value[1:-3]
                    if document == document_name:
                        iacs = set()
                        for pdi in reqs:
                            try:
                                iacs.update(set(map[pdi]))
                            except KeyError:
                                log.error('%s PDI %r, possibly written '
                                        'in file %s, is not described '
                                        'in XCCDF file %s',
                                        document_name, pdi,
                                        last_new_file,
                                        meaning.filename)
                                # nothing added to iacs. fine.
                        we_care_about = sorted(list(
                                set(iacs) & set(pertinent_ia_controls)) )
                        if len(we_care_about) > 0:
                            target.send(
                                    (requirement_tag,) + other +
                                    ('iacontrol', we_care_about, True) )
            else:
                pass
    return coro
