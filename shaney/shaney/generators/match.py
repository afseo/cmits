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
import re

def tagged_match(tag, regex):
    """Do something when a tag and a regex both match; passthrough.

    Constructs generators that take as input any of the following
    tuples:
        (tag, line)
        (any other string, anything)
    Output:
        (depends on the function tagged_match is decorating)
        (any other string, anything)
    Passes messages through.

    Example::
        @tagged_match('toplevel', r"^bla")
        def bla_at_beginning(match, value, target):
            target.send( ('i_saw_a_bla',) )
            # pass value through
            target.send(value)

        coro = bla_at_beginning(my_target)
    After this, coro is a coroutine which expects to be sent tuples
    (tag, value), like coro.send((tag, value)). It will send things on
    to my_target in like manner. If the tag is 'toplevel', and the regex
    matches, the body of bla_at_beginning will be called with the match.
    If either condition is not true, the value will be sent through to
    the target unmodified. (This behavior is not written in the body of
    bla_at_beginning; it's part of tagged_match.)
    
    Consequently if you have a pipeline A B C D E of such coroutines,
    where B is A's target, C is B's target and so on, the output at E's
    target will be at least what was input, and maybe more, if some of
    the regexes matched.
    """
    log = logging.getLogger('tagged_match')
    def gets_block(fn):
        def matcher(target):
            while True:
                value = (yield)
                if value[0] == tag:
                    text = value[1].strip()
                    m = re.findall(regex, text)
                    if m:
                        fn(m, value, target)
                    else:
                        target.send(value)
                else:
                    target.send(value)
        return matcher
    return gets_block

def tagged_match_or_drop(tag, regex):
    """Do something when a tag and a regex both match; no passthrough.

    Constructs generators that take as input any of the following
    tuples:
        (tag, line)
        (any other string, anything)
    Output:
        (depends on the function tagged_match is decorating)
    Does not pass messages through.

    Example::
        @tagged_match_or_drop('toplevel', r"^bla")
        def bla_at_beginning(match, value, target):
            target.send( ('i_saw_a_bla',) )

        coro = bla_at_beginning(my_target)
    After this, coro is a coroutine which expects to be sent tuples
    (tag, value), like coro.send((tag, value)). It will send only
    ('i_saw_a_bla',) tuples on to my_target.
    
    Consequently if you have a pipeline A B C D E of such coroutines,
    where B is A's target, C is B's target and so on, the output at E's
    target will be solely what E decided to say about what D said.
    """
    log = logging.getLogger('tagged_match_or_drop')
    def gets_block(fn):
        def matcher(target):
            while True:
                value = (yield)
                if value[0] == tag:
                    text = value[1].strip()
                    m = re.findall(regex, text)
                    if m:
                        fn(m, value, target)
        return matcher
    return gets_block

@tagged_match('toplevel', r'\\verb(.)([^\1]*)\1')
def neutralize_verb_tag(m, value, target):
    logging.getLogger('neutralize_verb_tag').debug('found a verb tag; m is %r', m)
    neutralized = value[1]
    # just in case there's more than one \verb
    for a_match in m:
        neutralized = neutralized.replace(r'\verb%s%s%s' % (
            a_match[0], a_match[1], a_match[0]), r'\verb!...!')
    target.send( (value[0], neutralized) )
