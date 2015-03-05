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
from upd_builder.sort_manifests import puppet_key

class TestPuppetSort(unittest.TestCase):
    def test_same_dir_normal(self):
        "Files are normally sorted alphabetically"
        ab = ['/foo/bar/blart.pp', '/foo/bar/baz.pp']
        ab = sorted(ab, key=puppet_key)
        self.assertEqual(ab, ['/foo/bar/baz.pp', '/foo/bar/blart.pp'])

    def test_same_dir_init(self):
        "init.pp comes first in a directory"
        ab = ['/foo/bar/blart.pp', '/foo/bar/init.pp']
        ab = sorted(ab, key=puppet_key)
        self.assertEqual(ab, ['/foo/bar/init.pp', '/foo/bar/blart.pp'])

    def test_same_dir_site_init(self):
        "site.pp comes first, but after init.pp"
        ab = ['/foo/bar/blart.pp', '/foo/bar/site.pp', '/foo/bar/init.pp']
        ab = sorted(ab, key=puppet_key)
        self.assertEqual(ab, ['/foo/bar/init.pp', '/foo/bar/site.pp',
                              '/foo/bar/blart.pp'])

    def test_analogous_dir(self):
        "sub-sub-module files go right after the sub-module"
        ab = [
                '/foo/bar/aardvark.pp',
                '/foo/bar/balloon.pp',
                '/foo/bar/init.pp',
                '/foo/bar/plane.pp',
                '/foo/bar/balloon/zeppelin.pp',
                '/foo/bar/balloon/blimp.pp',
            ]
        ab = sorted(ab, key=puppet_key)
        self.assertEqual(ab, [
            '/foo/bar/init.pp',
            '/foo/bar/aardvark.pp',
            '/foo/bar/balloon.pp',
            '/foo/bar/balloon/blimp.pp',
            '/foo/bar/balloon/zeppelin.pp',
            '/foo/bar/plane.pp',
        ])

    def test_multiple_inits(self):
        ab = [
                '/foo/bar/zart/init.pp',
                '/foo/bar/zart/other.pp',
                '/foo/bar/bletch/init.pp',
                '/foo/bar/bletch/other2.pp',
            ]
        ab = sorted(ab, key=puppet_key)
        self.assertEqual(ab, [
            '/foo/bar/bletch/init.pp',
            '/foo/bar/bletch/other2.pp',
            '/foo/bar/zart/init.pp',
            '/foo/bar/zart/other.pp',
        ])

    def test_different_modules_dirs(self):
        "all modules-* files are sorted together"
        ab = [
                '/foo/modules-foo/mod2/manifests/init.pp',
                '/foo/modules-ubb/mod1/manifests/init.pp',
            ]
        ab = sorted(ab, key=puppet_key)
        self.assertEqual(ab, [
            '/foo/modules-ubb/mod1/manifests/init.pp',
            '/foo/modules-foo/mod2/manifests/init.pp',
        ])

if __name__ == '__main__':
    unittest.main()
