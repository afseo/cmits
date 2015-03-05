#!/usr/bin/python2.6
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
import time
from shaney.sourapples.config import SourApplesConfig
from shaney.sourapples.build import build
from shaney.sourapples.tk_log import run_and_view_log

def main():
    # We depend entirely on the configuration file, not on command line
    # arguments, because we may not be executed from a command line.
    config = SourApplesConfig()

    # set up logging
    loglevel = getattr(logging, config.get('main', 'loglevel'))
    def thestuff():
        # Without this sleep, the Tk GUI under Windows freezes before it
        # shows itself. I have no idea why.
        time.sleep(0.5)
        build(config)
    run_and_view_log(thestuff, loglevel)

if __name__ == '__main__':
    main()
