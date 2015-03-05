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
import re
import logging
import os.path
from collections import defaultdict
from shaney.generators.labels import sanitize_label

#from shaney.generators.requirement import requirement_tags_to_interpret
# don't tag paragraphs with \bydefault in them
requirement_tags_to_interpret = ('implements', 'doneby')

def puppet_labels_for_per_iac(dirs_to_strip):
    def coro(target):
        log = logging.getLogger('puppet_labels_for_per_iac')
        while True:
            value = (yield)
            if value[0] == 'new_file':
                filename = value[1]
                pieces = filename.split(os.path.sep)[dirs_to_strip:]
                filename = os.path.sep.join(pieces)
                label = sanitize_label(filename)
                target.send( ('label_for_paragraph', label) )
    return coro

def latex_labels_for_per_iac(target):
    while True:
        x = (yield)
        if x[0] == 'toplevel':
            line = x[1].strip()
            m = re.findall('\\label{([^}]+)}', line)
            if m:
                target.send( ('label_for_paragraph', m[0]) )


def tag_iac_paragraphs(target):
    """Transcribe paragraphs notated as implementing IA controls.
    
    Input: tuples of the forms:
        ('new_file', filename)
        ('implements', 'iacontrol', 
                tuple of IA control identifiers, True or False)
        ('implements', any other string, anything)
        ('doneby', any string, 'iacontrol', 
                tuple of IA control identifiers, True or False)
        ('doneby', any string, any other string, anything)
        ('paragraph', tuple of strings)
        (any other string, anything)
    Output: tuples of the form:
        (IA control identifier, tuple of strings)
    Does not pass messages through.

    A given paragraph may pertain to more than one IA control; if so it
    will result in more than one output tuple.
    """
    log = logging.getLogger('per_iac_output')
    iacs_applying_to_next_paragraph = set()
    last_label = None
    last_cited = defaultdict(lambda: None)
    while True:
        value = (yield)
        if value[0] == 'label_for_paragraph':
            last_label = value[1]
        elif value[0] in requirement_tags_to_interpret:
            document, controls, derived = value[-3:]
            if document == 'iacontrol':
                iacs_applying_to_next_paragraph |= set(controls)
        elif value[0] == 'paragraph':
            lines = value[1]
            for iac in iacs_applying_to_next_paragraph:
                if last_label != last_cited[iac]:
                    target.send( (iac, ('excerpt_from', last_label)) )
                    last_cited[iac] = last_label
                for line in lines:
                    target.send( (iac, ('toplevel', line)) )
                # send blank line not included at end of para
                target.send( (iac, ('toplevel', '\n')) )
            iacs_applying_to_next_paragraph.clear()
