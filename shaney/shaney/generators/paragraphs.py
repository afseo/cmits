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
import re
import logging

def paragraphs(target):
    """Groups markup lines into paragraphs.

    Input: tuples of these forms:
        ('toplevel', line)
        ('verbatim', line)
    Output: tuples of these forms:
        ('paragraph', list of lines)
    Does not pass messages through.
    """
    at_toplevel = False
    accumulated = []
    log = logging.getLogger('paragraphs')
    def burp(message):
        if len(accumulated) > 0:
            # avoid sending empty paragraphs
            target.send( ('paragraph', tuple(accumulated)) )
            del accumulated[:]
    try:
        while True:
            value = (yield)
            if value[0] == 'end_of_file':
                # paragraph has ended
                burp('end of file')
            if value[0] == 'toplevel':
                line = value[1]
                blank_line = re.match(r'^\s*$', line)
                if at_toplevel:
                    if blank_line:
                        # blank line ends paragraph.
                        burp('blank line')
                    else:
                        # paragraph is continued by this line
                        accumulated.append(line)
                else:
                    accumulated.append(value[1])
                at_toplevel = True
            elif value[0] == 'verbatim':
                if at_toplevel:
                    # verbatim line ends paragraph.
                    burp('toplevel line after verbatim')
                else:
                    # we continue in the verbatim
                    pass
                at_toplevel = False
            else:
                pass
    except GeneratorExit:
        # whatever we have accumulated is the last paragraph.
        burp('end of input')
