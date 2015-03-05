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
import os
import shutil
from glob import glob

from shaney.sourapples.config import SourApplesConfig

def rm_rf(*args):
    for a in args:
        for ga in glob(a):
            shutil.rmtree(ga, True)

def rm_f(*args):
    for a in args:
        for ga in glob(a):
            try:
                os.unlink(ga)
            except OSError:
                pass

def main():
    c = SourApplesConfig()
    rm_f('main.pdf')
    for sec in ('policy', 'attendant_files', 'per_iac', 'exec_summary'):
        rm_f(c.get(sec, 'output_file'))
    rm_f('*.aux', '*.log', '*.toc', '*.out')
    rm_f('*.idx', '*.ind', '*.ilg')
    rm_f('*.bbl', '*.blg')
    rm_rf(c.get('per_iac', 'output_dir'))


if __name__ == '__main__':
    main()
