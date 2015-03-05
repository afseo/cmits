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
import os.path
from shaney.generators import pipe, prime, log
from shaney.generators.latex import LatexEmitter
from shaney.generators.output import lines_to_file

class AbracaDict(dict):
    """Construct items when they don't exist, and remember them.

    This is suspiciously similar to a defaultdict, but the defaultdict
    calls its factory with no arguments, and here we hand the factory
    one argument.
    """
    def __init__(self, factory):
        self.factory = factory
    def __getitem__(self, name):
        if not self.has_key(name):
            self[name] = self.factory(name)
        return super(AbracaDict, self).__getitem__(name)


def latex_to_files_in(directory_name, iac_titles):
    """Write lines to any of several files.

    Input: tuples of the form:
        (filename, anything)
    Output: nothing, to the given target.

    Sends each "anything" to a LatexEmitter pointed at the named file in
    the directory passed as a parameter.

    Closes all files when the input ends.
    """
    def coro(target):
        def summon_file_for_iac(iac):
            f = file(os.path.join(directory_name, iac), 'w')
            print >> f, "\\section{%s: %s}" % (iac, iac_titles[iac])
            print >> f, "\\label{iac-%s}" % iac
            return prime(pipe(
                LatexEmitter(iac),
                prime(lines_to_file(f)(None))))
        outputs = AbracaDict(summon_file_for_iac)
        try:
            while True:
                # this particular generator is constructed, used for one
                # thing, then passed to a pipe call for another purpose,
                # which tries to prime it again. this is a horrible
                # hack:
                thing = (yield)
                if thing is not None:
                    iac, message = thing
                    outputs[iac].send(message)
        except GeneratorExit:
            for g in outputs.values():
                g.close()
    return coro

