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
import logging
import os

def make_walk_and_prune(prune_dirs_named=[]):
    """Make a function that walks dir, not traversing into some subdirs.
    prune_dirs_named is a list of directory names into which not to
    traverse. Returns a function that works like os.walk.
    """
    log = logging.getLogger('walk_and_prune')
    def walk_and_prune(dir):
        for root, dirs, files in os.walk(dir):
            yield (root, dirs, files)
            for pd in prune_dirs_named:
                if pd in dirs:
                    dirs.remove(pd)
    return walk_and_prune

def puppet_manifests_under(dir, walker=os.walk):
    """Find all the Puppet files under dir.

    We reject SELinux policy packages (which also have the extension
    'pp') which must have the extension *.selinux.pp. The alternative is
    to exclude all files under */files/* directories, but then if anyone
    writes a module or submodule called files, the Puppet manifests
    inside it would mysteriously not be shown.
    """
    for root, dirs, files in walker(dir):
        for f in files:
            if f.endswith('.pp') and not f.endswith('.selinux.pp'):
                yield os.path.join(root, f)

def attendant_files_under(dir, walker=os.walk,
        assumed_path_element='files'):
    strings = {
            'S': os.path.sep,
            'A': assumed_path_element,
    }
    for root, dirs, files in walker(dir):
        # Anywhere under a directory named assumed_path_element, yield
        # all files.
        if root.endswith('%(S)s%(A)s' % strings) \
                or ('%(S)s%(A)s%(S)s' % strings) in root:
            for f in files:
                yield os.path.join(root, f)

def latex_files_under(dir, walker=os.walk):
    for root, dirs, files in walker(dir):
        for f in files:
            if f.endswith('.tex') and not f.startswith('.'):
                yield os.path.join(root, f)
