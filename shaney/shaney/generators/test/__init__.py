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
import unittest
import new
from shaney.generators import prime, identity

class Sink(object):
    """A coroutine which saves everything it receives for analysis."""
    def __init__(self):
        self.values = []

    def __call__(self, target=None):
        while True:
            value = (yield)
            self.values.append(value)

# You will not be tested on the next 22 lines.
# They just make it so that if you use the -v switch to the test runner,
# for each test class you will see the first line of the docstring of
# the class.

# http://stackoverflow.com/questions/100003/what-is-a-metaclass-in-python
# http://stackoverflow.com/questions/71817/using-the-docstring-from-one-method-to-automatically-overwrite-that-of-another-m
def _copyfunc(func):
    return new.function(func.func_code, func.func_globals,
            func.func_name, func.func_defaults, func.func_closure)

class CooptClassDocstringMeta(type):
    """Set the docstring of the test method to the docstring of the class."""
    def __new__(cls, name, bases, dct):
        if '__doc__' in dct and 'runTest' not in dct:
            test_method = None
            for parent in bases:
                if hasattr(parent, 'runTest'):
                    test_method = getattr(parent, 'runTest')
            if test_method is None:
                raise Exception('could not find test method')
            test_method_func = test_method.im_func
            new_tmf = _copyfunc(test_method_func)
            new_tmf.func_doc = dct['__doc__']
            dct['runTest'] = new.instancemethod(new_tmf,
                    test_method.im_self, test_method.im_class)
        return type.__new__(cls, name, bases, dct)

class CoroutineTest(unittest.TestCase):
    # You can't say """ inside of a triple-quoted string, you have to
    # say ""\". So when you see ""\" in the example it means you should
    # write """. Also you have to escape backslashes in a non-raw
    # string, so \\ below means \.
    """Test a coroutine, which is sent some things, and sends some.

    http://www.slideshare.net/dabeaz/python-generator-hacking

    Usually generators go like so::

        >>> def source():
        ...     for x in [0,1,2,3,4]:
        ...         yield x
        ... 
        >>> def middle(source):
        ...     for x in source:
        ...         yield x + 2
        ... 
        >>> def consumer(source):
        ...     for x in source:
        ...         print x,
        ... 
        >>> consumer(middle(source()))
        2 3 4 5 6

    These happen on a pull basis. But we can make coroutines, which are
    like push-based generators, like so::

        >>> def source(target):
        ...     for x in [0,1,2,3,4]:
        ...         target.send(x)
        ... 
        >>> def middle(target):
        ...     while True:
        ...         x = (yield)
        ...         target.send(x + 2)
        ... 
        >>> def consumer():
        ...     while True:
        ...         x = (yield) 
        ...         print x,
        ... 
        >>> c = consumer()
        >>> c.next()
        >>> m = middle(c)
        >>> m.next()
        >>> source(m)
        2 3 4 5 6

    The advantage is that with these it's easier to route the output
    to multiple places, without caching huge amounts of anything.

    Any coroutine like this is going to consume some values, and
    probably produce some (like middle above). To unit-test it, you poke
    some values in, and you expect some back out. The values change, but
    the way to do the test does not. To write a test like this
    succinctly, use this class. As an example::

        class TestMiddle(CoroutineTest):
            ""\"middle yields its argument plus two:""\"
            coroutine_under_test = middle
            send = [0, 2, 4]
            expect = [2, 4, 6]
    """
    __metaclass__ = CooptClassDocstringMeta
    coroutine_under_test = identity
    send = []
    expect = []
    def preprocess_send(self):
        """Transform send in some way, to get a stream of things to send."""
        # This is the identity transform
        for x in self.send:
            yield x
    def preprocess_expect(self):
        """Transform expect in some way."""
        for x in self.expect:
            yield x
    def runTest(self):
        # This docstring will show up in nosetests -v and python
        # test_bla.py -v output. The metaclass above replaces this empty
        # string in subclasses of CoroutineTest with the docstring from
        # the subclass.
        "."
        s = Sink()
        sink_gen = prime(s())
        # The thing assigned to coroutine_under_test was a callable of
        # some sort. But somewhere along the line, it's made into an
        # instancemethod, so that when it's called, the self parameter
        # is prepended to the argument list. But we don't want that
        # here: we're just trying to store a callable in self and get it
        # back out later, no special behavior. So pull the func back out
        # of the instancemethod and use that.
        #
        # But if the callable was not a function, it won't have been
        # packaged into an instancemethod. For example, it may have been
        # an instance of a class having a __call__ method.
        if hasattr(self.coroutine_under_test, 'im_func'):
            coro = self.coroutine_under_test.im_func
        else:
            coro = self.coroutine_under_test
        send_into = prime(coro(sink_gen))
        for thing in self.preprocess_send():
            send_into.send(thing)
        send_into.close()
        self.assertEqual(s.values, list(self.preprocess_expect()))
