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
from shaney.generators import prime, splitmerge

def find(needle):
    def coro(target):
        while True:
            x = (yield)
            if needle in x:
                target.send('%s found' % needle)
    return coro

class CommonSend(object):
    send = [
            'the quick brown fox jumped over the lazy dog',
            'she sells seashells by the seashore',
            'dennis, there\'s some lovely filth over here',
            'well, she turned me into a newt',
            'a newt?',
            '...',
            'i got better',
            'fox news',
        ]

class TestSingleFind(CommonSend, CoroutineTest):
    coroutine_under_test = find('fox')
    expect = [
            'fox found',
            'fox found',
        ]


class TestSplitMerge(CommonSend, CoroutineTest):
    coroutine_under_test = splitmerge(find('fox'), find('newt'))
    expect = [
            'fox found',
            'newt found',
            'newt found',
            'fox found',
        ]


if __name__ == '__main__':
    unittest.main()
