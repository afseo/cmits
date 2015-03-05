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
import shaney.event

class TestEventer(unittest.TestCase):
    def testFire(self):
        class Receives(object):
            received = False
            def on_fire(self):
                self.received = True
        r = Receives()
        s = shaney.event.Eventer()
        s.add_listener(r)
        s.emit_fire()
        self.assertEqual(r.received, True)

if __name__ == '__main__':
    unittest.main()
