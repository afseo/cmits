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

class TestFaxlore(unittest.TestCase):
    def testLabelForFilename(self):
        """Every time we begin a new input file, faxlore emits a label...
        
        after the first line of the file. If the first line of the file
        is a new \section, and we emit the filename label before that
        new \section, the label will point to the end of the previous
        section, not the beginning of this one. See [4557].
        """
        m = Mock()
        f = shaney.faxlore.Faxlore(emitter=m, dirs_to_strip=2)
        f.on_new_file('../../manifests/foo.pp')
        f.on_line('# just some LaTeX')
        self.assertEqual(m.calls, [
            ('toplevel', (' just some LaTeX',), {}),
            ('label', ('manifests/foo.pp',), {})])

    def testLabelForModule(self):
        """Labels are emitted for each module."""
        m = Mock()
        f = shaney.faxlore.Faxlore(emitter=m, dirs_to_strip=2)
        f.on_new_file('../../modules/foo/manifests/init.pp')
        f.on_line('# just some LaTeX')
        self.assertEqual(m.calls, [
            ('toplevel', (' just some LaTeX',), {}),
            ('label', ('modules/foo/manifests/init.pp',), {}),
            ('label', ('module_foo',), {}),])

    def testNoDuplicateModuleLabels(self):
        """Per-module labels are emitted only once for each module."""
        m = Mock()
        f = shaney.faxlore.Faxlore(emitter=m, dirs_to_strip=2)
        f.on_new_file('../../modules/foo/manifests/bar.pp')
        f.on_line('# just some LaTeX')
        self.assertEqual(m.calls, [
            ('toplevel', (' just some LaTeX',), {}),
            ('label', ('modules/foo/manifests/bar.pp',), {})])


    def testStraightPuppet(self):
        """Puppet code is output in verbatim blocks."""
        m = Mock()
        f = shaney.faxlore.Faxlore(emitter=m, dirs_to_strip=2)
        f.on_new_file('../../manifests/foo.pp')
        f.on_line('puppet code')
        f.on_line('more puppet code')
        f.on_end_of_input()
        self.assertEqual(m.calls, [
            ('label', ('manifests/foo.pp',), {}),
            ('verbatim', ('puppet code',), {}),
            ('verbatim', ('more puppet code',), {}),
            ('end', (), {})])

    def testStraightLatex(self):
        """Commented code is treated as LaTeX input."""
        m = Mock()
        f = shaney.faxlore.Faxlore(emitter=m, dirs_to_strip=2)
        f.on_new_file('../../manifests/foo.pp')
        f.on_line('# some latex code')
        f.on_end_of_input()
        self.assertEqual(m.calls, [
            ('toplevel', (' some latex code',), {}),
            ('label', ('manifests/foo.pp',), {}),
            ('end', (), {})])

if __name__ == '__main__':
    unittest.main()
