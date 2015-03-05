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
from shaney import xccdfmeaning as m

class TestFixUnescaped(unittest.TestCase):
    def setUp(self):
        self.messages = []

    def logFunction(self, msg):
        self.messages.append(msg)

    def testEverythingWrittenRight(self):
        x = """<?xml version="1.0" ?><x>
            &lt;&gt;&amp; &lt; &gt; &amp;</x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out, x)
        self.assertEqual(len(self.messages), 0)

    def testUnescapedAmpersand(self):
        x = """<?xml version="1.0" ?><x>
            foo & bar</x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out,
            """<?xml version="1.0" ?><x>
            foo &amp; bar</x>""")
        self.assertEqual(len(self.messages), 1)

    def testUnescapedTightAmpersand(self):
        """fix_unescaped isn't a magic bullet:

        If the unescaped ampersand doesn't have spaces or line
        boundaries on both sides, it's hard to pick out whether it was
        meant as an ampersand, or as a part of some XML syntax. But
        nobody so far has written one of these, so we just don't sweat
        it.

        This test serves to document a quirk, not a requirement.
        """
        x = """<?xml version="1.0" ?><x>
            foo& bar</x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out,
            """<?xml version="1.0" ?><x>
            foo& bar</x>""")
        self.assertEqual(len(self.messages), 0)

    def testMoreComplicatedProblem(self):
        """fix_unescaped isn't a magic bullet:

        As above, if the unescaped entities don't have space on both
        sides, we can't really pick them out easily. This is just
        another case that I imagined while writing the above case, but
        this one is more likely to happen.

        Again, this test documents a quirk, not a requirement.
        """
        x = """<?xml version="1.0" ?><x>
            command >& out_and_error</x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out,
            """<?xml version="1.0" ?><x>
            command >& out_and_error</x>""")
        self.assertEqual(len(self.messages), 0)

    def testUnescapedRightAngleBracket(self):
        x = """<?xml version="1.0" ?><x>
            command > outfile</x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out,
            """<?xml version="1.0" ?><x>
            command &gt; outfile</x>""")
        self.assertEqual(len(self.messages), 1)

    def testUnescapedLeftAngleBracket(self):
        x = """<?xml version="1.0" ?><x>
            command < inputfile</x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out,
            """<?xml version="1.0" ?><x>
            command &lt; inputfile</x>""")
        self.assertEqual(len(self.messages), 1)

    def testProblemsInARow(self):
        """Syntax errors right beside each other are fixed:

        A regex-based solution that doesn't use zero-width
        lookahead/lookbehind assertions will eat up whitespace that
        separates problem characters; then the whitespace will not be
        there to surround the next problem character, and it will not be
        found. This test makes sure that problems right next to each
        other are still fixed.
        """
        x = """<?xml version="1.0" ?><x>
            have fun with this: < > &
            < & > > & <
            </x>"""
        out = m.fix_unescaped(x, self.logFunction)
        self.assertEqual(out,
            """<?xml version="1.0" ?><x>
            have fun with this: &lt; &gt; &amp;
            &lt; &amp; &gt; &gt; &amp; &lt;
            </x>""")
        self.assertEqual(len(self.messages), 3)

if __name__ == '__main__':
    unittest.main()
