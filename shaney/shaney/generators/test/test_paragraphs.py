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
from shaney.generators.paragraphs import paragraphs

class TestToplevelParagraphs(CoroutineTest):
    coroutine_under_test = paragraphs
    send = [
            ('implements', 'unixstig', ('BLABLA',), False),
            ('implements', 'iacontrol', ('IAC-1',), True),
            ('toplevel', '\implements{unixstig}{BLABLA} Do stuff.\n'),
            ('toplevel', 'And some other stuff.\n'),
            ('toplevel', '\n'),
            ('toplevel', 'A second paragraph.\n'),
            ('toplevel', '\n'),
        ]
    expect = [
            ('paragraph', (
                '\implements{unixstig}{BLABLA} Do stuff.\n',
                'And some other stuff.\n',
                )),
            ('paragraph', (
                'A second paragraph.\n',
                )),
        ]

class TestToplevelLastParagraph(CoroutineTest):
    coroutine_under_test = paragraphs
    send = [
            ('toplevel', 'No blank line, but at end of input.\n'),
        ]
    expect = [
            ('paragraph', ('No blank line, but at end of input.\n',)),
        ]

class TestToplevelAndVerbatim(CoroutineTest):
    coroutine_under_test = paragraphs
    send = [
            ('toplevel', 'A toplevel line.\n'),
            ('verbatim', 'A verbatim line.\n'),
            ('toplevel', 'End of input.\n'),
        ]
    expect = [
            ('paragraph', ('A toplevel line.\n',)),
            ('paragraph', ('End of input.\n',)),
        ]



if __name__ == '__main__':
    unittest.main()
