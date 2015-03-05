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
import subprocess
import logging

def make_run_and_log_if_error(executable):
    log = logging.getLogger('executing')
    sui = None
    if hasattr(subprocess, 'STARTUPINFO'):
        # We are running under Windows. Tell Windows not to open up
        # a console window for this subprocess.
        # http://code.activestate.com/recipes/409002-launching-a-subprocess-without-a-console-window/
        sui = subprocess.STARTUPINFO()
        sui.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    def execute(*args):
        to_exec = (executable,) + args
        log.info(' '.join(to_exec))
        p = subprocess.Popen((executable,) + args,
                stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                stderr=subprocess.PIPE, startupinfo=sui)
        out, err = p.communicate(None)
        if p.returncode != 0:
            for line in out.split('\n'):
                log.error('stdout: %s', line)
            for line in err.split('\n'):
                log.error('stderr: %s', line)
            raise subprocess.CalledProcessError(p.returncode,
                    to_exec)
    return execute

