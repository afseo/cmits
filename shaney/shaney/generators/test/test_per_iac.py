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
from shaney.generators import pipe, log, splitmerge, identity
from shaney.generators.test import CoroutineTest
from shaney.generators.paragraphs import paragraphs
from shaney.generators.per_iac import per_iac_output

class TestSingleParagraph(CoroutineTest):
    coroutine_under_test = per_iac_output
    send = [
            ('implements', 'unixstig', ('BLABLA',), False),
            ('implements', 'iacontrol', ('IAC-1',), True),
            ('paragraph', (
                '\implements{unixstig}{BLABLA} Do stuff.\n',
                'And some other stuff.\n',
                 )),
            ('paragraph', (
                'A second paragraph.\n',
                )),
        ]
    expect = [
            ('IAC-1', (
                '\implements{unixstig}{BLABLA} Do stuff.\n',
                'And some other stuff.\n',
                )),
        ]



if __name__ == '__main__':
    unittest.main()
