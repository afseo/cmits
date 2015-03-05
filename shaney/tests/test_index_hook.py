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
import shaney.faxlore
from cStringIO import StringIO

# This mock class is crappy and incomplete, and there is a Python mock
# module. But heaven forbid we should use software that exists; that
# would be insecure.
class Mock(object):
    def __init__(self):
        self.calls = []
        self.getattrs = []

    def __getattr__(self, name):
        self.getattrs.append(name)
        def recordkeeper(*args, **kwargs):
            self.calls.append((name, args, kwargs))
        return recordkeeper

class TestIndexHook(unittest.TestCase):
    def testIncludeParameter(self):
        """The index hook rejects false class includes [4594]."""
        m = Mock()
        shaney.faxlore.index_hook('    include => "foo",', m)
        if len(m.calls) > 0:
            self.fail('index_hook wrongly indexed an unfortunately-' \
                    'named class parameter')

    def testIncludeColonColon(self):
        """The index hook accepts nested class includes [4595]."""
        m = Mock()
        shaney.faxlore.index_hook('    include a::b', m)
        self.assertEqual(m.calls, [
            ('index_entry', ('class', 'a::b'), {}),])

    def testIncludeDashInName(self):
        """The index hook accepts includes with dashes in the class name
        [4597]."""
        m = Mock()
        shaney.faxlore.index_hook('    include a-b', m)
        self.assertEqual(m.calls, [
            ('index_entry', ('class', 'a-b'), {}),])

if __name__ == '__main__':
    unittest.main()
