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

def executive_summary(iac_names):
    """Make an `executive summary` of IA controls implemented.

    An executive summary, as defined, is a table of which IA controls
    this document covers. To construct one, we listen for all
    IA controls implemented, accumulate a set, and output it at the end
    of all things.

    Input: tuples of these forms:
        ('implements', 'iacontrol', tuple of IA control identifiers)
        ('implements', any other string, anything)
        (any other string, anything)
    Output: tuples of these forms:
        ('begin_execsummary',)
        ('execsummary_iacontrol', 
                IA control identifier,
                IA control title)
        ('end_execsummary',)
    Does not pass messages through.
    """
    log = logging.getLogger('executive_summary')
    def coro(target):
        implements = set()
        try:
            while True:
                value = (yield)
                if value is None:
                    pass
                elif value[0] == 'implements':
                    if value[1] == 'iacontrol':
                        implements |= set(value[2])
        except GeneratorExit:
            target.send( ('begin_execsummary',) )
            for imp in sorted(list(implements)):
                target.send( ('execsummary_iacontrol', imp, iac_names[imp]) )
            target.send( ('end_execsummary',) )
    return coro
