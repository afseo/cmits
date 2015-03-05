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
import unittest
from shaney.generators.test import CoroutineTest
from shaney.generators.exec_summary import executive_summary

class TestToplevelParagraphs(CoroutineTest):
    coroutine_under_test = executive_summary({
        'IAC-1': 'Time Waste Efficiency',
        'IAC-2': 'Prohibited Features Used Properly'})
    send = [
            ('implements', 'unixstig', ('BLABLA',), False),
            ('implements', 'iacontrol', ('IAC-1',), True),
            ('toplevel', '\implements{unixstig}{BLABLA} Do stuff.\n'),
            ('toplevel', 'And some other stuff.\n'),
            ('toplevel', '\n'),
            ('verbatim', 'bla\n'),
            ('implements', 'iacontrol', ('IAC-2',), False),
            ('toplevel', 'A second paragraph.\n'),
            ('toplevel', '\n'),
        ]
    expect = [
            ('begin_execsummary',),
            ('execsummary_iacontrol', 'IAC-1', 'Time Waste Efficiency'),
            ('execsummary_iacontrol', 'IAC-2',
                'Prohibited Features Used Properly'),
            ('end_execsummary',),
        ]

if __name__ == '__main__':
    unittest.main()
