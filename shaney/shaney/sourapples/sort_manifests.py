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
from os.path import sep

def puppet_key(x):
    """Sort full path names of Puppet manifest files in a way that makes sense.

    Making sense is defined as:
    * init.pp comes first in a directory, then site.pp, then everything else;
    * all foo/*.pp come right after foo.pp;
    * other than that, files and directories are sorted alphabetically within a
      directory.
    """

    # ('a',) < ('a', 'b') < ('b',)
    x = x.split(sep)
    # different modules directories should all be sorted together.
    # In Python 2.5 or later, we would say
    #   ['modules' if a.startswith('modules-') else a for a in x]
    x = [a.startswith('modules-') and 'modules' or a for a in x]
    # it appears that any number is less than a string
    if x[-1].endswith('init.pp'):
        x[-1] = 0
    elif x[-1].endswith('site.pp'):
        x[-1] = 1
    else:
        # where a is a puppet file, we strip off the suffix so it will
        # come before its sub-files
        if x[-1].endswith('.pp'):
            x[-1] = x[-1][:-len('.pp')]
    return x
