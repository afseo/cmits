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

import sys
import os.path
import logging

def parse_compliance(compliance_aux):
    compliance = {}
    for l in compliance_aux:
        document, requirement, status = l.strip().split(':')
        compliance.setdefault(document, {})
        compliance[document][requirement] = status
    return compliance

def parse_explanations(explanations_aux):
    explanations = {}
    state = 0
    lastd = None
    lastr = None
    for l in explanations_aux:
        if state == 0:
            document, requirement, throwaway = l.strip().split(':')
            explanations.setdefault(document, {})
            explanations[document][requirement] = ''
            lastd = document
            lastr = requirement
            state = 1
        elif state == 1:
            if l.strip() == ':':
                state = 0
            else:
                explanations[lastd][lastr] += l
    return explanations

def table_rows(docname, meaning, compliance_for_document,
        explanations_for_document):
    yield (
        'STIG',
        'STIG ID',
        'IA Controls',
        'Title',
        'Rule ID',
        'Severity',
        'Compliant?',
        'Explanation/Mitigation',
        )
    for rg in meaning.selected_rule_groups():
        for r in rg.rules():
            try:
                compliant = compliance_for_document[r.version]
            except KeyError:
                compliant = '(nothing written)'
            try:
                explanation = explanations_for_document[r.version]
            except KeyError:
                explanation = ''
            yield (
                    docname,
                    r.version,
                    ', '.join(rg.ia_controls),
                    r.title,
                    r.id,
                    r.severity,
                    compliant,
                    explanation,
                    )

def values_to_csv(iterable_of_tuples):
    for row in iterable_of_tuples:
        # HACK: replace double quotes in values with single quotes, so that
        # when we use double quotes to delimit values, quotes inside the
        # values won't screw up the file format
        yield u','.join(u'"%s"' % (x.replace('"', "'")) for x in row)


def compliance2csv(checklists, compliance_aux, explanations_aux):
    """Read aux files created by LaTeX and yield CSV table of compliance.

    meaning is an XCCDFMeaning object.

    compliance_aux and explanations_aux are iterables of lines from a
    the respective files (e.g., open file objects).
    """
    log = logging.getLogger('compliance2csv')
    compliance = parse_compliance(compliance_aux)
    explanations = parse_explanations(explanations_aux)
    for docname, meaning in checklists.items():
        if docname in compliance:
            this_compliance = compliance[docname]
        else:
            log.warning('no notations of compliance found for %s',
                    docname)
            this_compliance = {}
        if docname in explanations:
            this_explanations = explanations[docname]
        else:
            log.info('no explanations of non-compliance '
                    'found for %s. (Maybe there is no '
                    'non-compliance to explain!)',
                    docname)
            this_explanations = {}
        rows = table_rows(docname, meaning, this_compliance, this_explanations)
        for x in values_to_csv(rows):
            yield x
