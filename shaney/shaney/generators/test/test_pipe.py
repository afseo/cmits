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
from shaney.generators.test import Sink
from shaney.generators import prime, pipe

def add(y):
    def g(target):
        while True:
            x = (yield)
            target.send(x+y)
    return g

def mul(y):
    def g(target):
        while True:
            x = (yield)
            target.send(x*y)
    return g

class TestPipe(unittest.TestCase):
    def testZeroMemberPipe(self):
        self.assertRaises(ValueError, pipe)

    def testOneMemberPipe(self):
        s = Sink()
        # pipe will call s() to get generator object
        p = prime(pipe(s))
        p.send(3)
        self.assertEqual(s.values, [3])

    def testTwoMemberPipe(self):
        s = Sink()
        sg = prime(s())
        p = prime(pipe(add(1), sg))
        p.send(3)
        self.assertEqual(s.values, [4])

    def testThreeMemberPipe(self):
        s = Sink()
        sg = prime(s())
        p = prime(pipe(add(1), mul(3), sg))
        p.send(4)
        # add(1) happens first -> 5
        # then mul(3) -> 15
        self.assertEqual(s.values, [15])

if __name__ == '__main__':
    unittest.main()
