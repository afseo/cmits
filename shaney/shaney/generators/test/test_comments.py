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
import unittest
from shaney.generators.test import CoroutineTest
from shaney.generators.comments import sort_comments, invert_comments

class TestSortComments(CoroutineTest):
    coroutine_under_test = sort_comments
    send = [
            ('new_file', 'foo'),
            ('line', '#!a hashbang'),
            ('line', '# commented line 1'),
            ('line', 'uncommented line 2'),
            ('line', '# commented line 3'),
        ]
    expect = [
            ('comment', ' commented line 1'),
            ('toplevel', 'uncommented line 2'),
            ('comment', ' commented line 3'),
        ]

class TestInvertComments(CoroutineTest):
    coroutine_under_test = invert_comments
    send = [
            ('comment', ' commented line 1'),
            ('toplevel', 'uncommented line 2'),
            ('comment', ' commented line 3'),
        ]
    expect = [
            ('toplevel', ' commented line 1'),
            ('verbatim', 'uncommented line 2'),
            ('toplevel', ' commented line 3'),
        ]

if __name__ == '__main__':
    unittest.main()
