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
def sort_comments(target):
    """Tease apart comments and non-comments; ignore hashbangs.
    
    Input: tuples of these forms:
        ('new_file', filename)
        ('line', line)
        (any other string, anything)
    Output: tuples of these forms:
        ('comment', line minus comment mark)
        ('toplevel', line)
    Does not pass messages through.
    """
    first_line = True
    while True:
        value = (yield)
        if value[0] == 'new_file':
            first_line = True
        elif value[0] == 'line':
            line = value[1]
            if first_line:
                if line.startswith('#!'):
                    # ignore
                    continue
            if line.startswith('#'):
                target.send( ('comment', line[1:]) )
            else:
                target.send( ('toplevel', line) )
        else:
            pass

def invert_comments(target):
    """Turn comments into toplevel, and toplevel into verbatim.

    Things written at the top level of a Puppet source file are Puppet
    code; things written in the comments are marked-up text meant for a
    formatter (we assume that formatter is LaTeX).

    But by the time we get to emitting the input that the formatter is
    intended to see, things written at the top level are marked-up text,
    and things written in verbatim blocks are Puppet code.

    This coroutine translates the sense of usual text from that of
    Puppet code to that of the document to be formatted.

    Input: tuples of these forms:
        ('comment', line)
        ('toplevel', line)
        (any other string, anything)
    Output: tuples of these forms:
        ('toplevel', line)
        ('verbatim', line)
        (any other string, anything)
    Passes messages through.
    
    """
    while True:
        value = (yield)
        if value[0] == 'comment':
            target.send( ('toplevel',) + value[1:] )
        elif value[0] == 'toplevel':
            target.send( ('verbatim',) + value[1:] )
        else:
            target.send(value)


