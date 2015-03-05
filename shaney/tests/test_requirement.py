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
import shaney.requirement
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

class MockWith(Mock):
    def __init__(self, *methodnames):
        super(MockWith, self).__init__()
        for m in methodnames:
            # make each method be in dir(aninstance)
            setattr(self, m, getattr(self, m))

class TestRequirement(unittest.TestCase):
    def testImplements1(self):
        m = MockWith('on_implements')
        f = shaney.requirement.FindRequirementTags()
        f.add_listener(m)
        f.on_line('# \implements{unixsrg}{GEN000300}')
        self.assertEqual(m.calls, [
            ('on_implements', ('unixsrg', ['GEN000300'], False), {})])

    def testImplementsMultiple(self):
        m = MockWith('on_implements')
        f = shaney.requirement.FindRequirementTags()
        f.add_listener(m)
        f.on_line('# \implements{unixsrg}{GEN000300,GEN000400}')
        self.assertEqual(m.calls, [
            ('on_implements', ('unixsrg', [
                'GEN000300', 'GEN000400'], False), {})])

    def testDoneby1(self):
        m = MockWith('on_doneby')
        f = shaney.requirement.FindRequirementTags()
        f.add_listener(m)
        f.on_line('# \doneby{admins}{unixsrg}{GEN000300}')
        self.assertEqual(m.calls, [
            ('on_doneby', ('admins', 'unixsrg', ['GEN000300'], False), {})])


if __name__ == '__main__':
    unittest.main()
