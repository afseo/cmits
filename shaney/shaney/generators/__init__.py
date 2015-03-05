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

def prime(g):
    """Prime a generator.

    For a generator x, you can't x.send(a_value) until you first
    call x.next() once. To save a line of code per generator, this
    function does that for you.

    Example::
        gen1 = fun_generator()
        gen1.next()
        # use gen1

        # -- or --
        gen1 = prime(fun_generator())
        # use gen1
    """
    g.next()
    return g

def pipe(*corofuncs):
    """Pipe generator coroutines together.
    
    For example, suppose you have three coroutines, a, b and c, each of
    which consumes values and sends something to its target; s, a
    source, which sends things; and t, which consumes values but doesn't
    send anything. Normally you would have to say something like this::

        t = prime(sink())
        c = prime(mul4(t))
        b = prime(add2(c))
        a = prime(negate(b))
        s = prime(source([2,3,4], a))

    With the pipe function, you can say this::

        p = prime(pipe(negate, add2, mul4, prime(sink())))
        s = prime(source([2,3,4], p))

    (Your editor does have parenthesis match highlighting, doesn't it?...)

    Each coroutine except the last must take one argument, the target.
    """
    if len(corofuncs) == 0:
        raise ValueError('a pipe must have more than 0 generators')
    # don't prime target
    thepipe = corofuncs[-1]
    if len(corofuncs) > 1:
        # >>> a = [0,1,2,3]
        # >>> a[-2:0:-1]
        # [2, 1]
        for previous in corofuncs[-2:0:-1]:
            thepipe = prime(previous(thepipe))
    # don't prime the last generator we stack on; that way the pipe will
    # be unprimed, as expected
    thepipe = corofuncs[0](thepipe)
    return thepipe

def identity(target):
    while True:
        x = (yield)
        target.send(x)

def null(target):
    while True:
        x = (yield)

def split(*targets):
    """Send output to multiple coroutines.

    You may find this difficult to use, because if more than one of the
    target coroutines has a common target, that target must already be
    bound to a variable, so that you can give its name. That means you
    have to construct latter parts of a pipeline before former ones.
    """
    while True:
        x = (yield)
        for t in targets:
            t.send(x)

def splitmerge(*corofuncs):
    """Send output to multiple coroutines, and gather it back again.
    """
    def coro(target):
        # hook up each coroutine to the same target, the given target;
        # this is the merge
        hooked_up = [prime(c(target)) for c in corofuncs]
        # now we split our input into each hooked_up coroutine
        return split(*hooked_up)
    return coro

def annotate_after(corofunc):
    return splitmerge(identity, corofunc)

def annotate_before(corofunc):
    return splitmerge(corofunc, identity)

def log(logger_name, log_level):
    l = logging.getLogger(logger_name)
    def coro(target):
        while True:
            x = (yield)
            l.log(log_level, '%r', x)
            target.send(x)
    return coro

def drop_tagged(tag):
    def coro(target):
        while True:
            value = (yield)
            if value[0] != tag:
                target.send(value)
    return coro

def take_tagged(tag):
    """Could have called this one grep."""
    def coro(target):
        while True:
            value = (yield)
            if value[0] == tag:
                target.send(value)
    return coro
