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
from shaney.generators.requirement import find_implements

class TestFindImplementsMatch(CoroutineTest):
    """find_implements can find an \\implements tag:"""
    coroutine_under_test = find_implements
    send = [
            ('toplevel', '\\implements{unixstig}{BLABLA} Do stuff.\n'),
        ]
    expect = [
            ('implements', 'unixstig', ('BLABLA',), False),
        ]

class TestFindMultipleOnSameLine(CoroutineTest):
    """find_implements deals with multiple \\implements tags on same line:
        
    In all likelihood, an actual human author would not write it like
    this, but like::

        \implements{unixstig}{BLABLA}
        \implements{apachestig}{BLUBLU}
        Do stuff.
    """
    coroutine_under_test = find_implements
    send = [
            ('toplevel', '\\implements{unixstig}{BLABLA} ' \
                '\\implements{apachestig}{BLUBLU} Do stuff.\n'),
        ]
    expect = [
            ('implements', 'unixstig', ('BLABLA',), False),
            ('implements', 'apachestig', ('BLUBLU',), False),
        ]

class TestMultipleRequirementsMet(CoroutineTest):
    """find_implements deals with multiple requirements in one statement:
    """
    coroutine_under_test = find_implements
    send = [
            ('toplevel', '\\implements{unixstig}{BLABLA,BLUBLU} Do stuff.'),
        ]
    expect = [
            ('implements', 'unixstig', ('BLABLA','BLUBLU'), False),
        ]


if __name__ == '__main__':
    unittest.main()
