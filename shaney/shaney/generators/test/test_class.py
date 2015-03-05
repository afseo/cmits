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

class ClassCoroutine(object):
    def __init__(self, state):
        self.state = state

    def __call__(self, target):
        while True:
            x = (yield)
            target.send(self.state)


class TestClassCoroutine(CoroutineTest):
    coroutine_under_test = ClassCoroutine('state')
    send = [3]
    expect = ['state']

if __name__ == '__main__':
    unittest.main()
