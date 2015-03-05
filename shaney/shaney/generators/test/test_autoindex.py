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
from shaney.generators.test import CoroutineTest
from shaney.generators.autoindex import autoindex
import new

class TestUnrecognizedPassesThrough(CoroutineTest):
    """Whatever the autoindexer does not care about, it sends through:"""
    coroutine_under_test = autoindex
    send = [
            ('comment', 'bla'),
            ('verbatim', ''),
            ('fnord', 'bletch'),
        ]
    expect = [
            ('comment', 'bla'),
            ('verbatim', ''),
            ('fnord', 'bletch'),
        ]


class AutoIndexTest(CoroutineTest):
    # You can't say """ inside of a triple-quoted string, you have to
    # say ""\". So when you see ""\" in the example it means you should
    # write """. Also you have to escape backslashes in a non-raw
    # string, so \\ below means \.
    """Test most properties of autoindex.

    The autoindexer expects to be sent tuples denoting what's going on
    in an input file, like this set::

        ('comment', 'some documentation about this Puppet class')
        ('verbatim', 'class puppetclass {')
        ('verbatim', '    mumble')
        ('verbatim', '}')

    It won't act on anything that isn't toplevel, so for most of our
    tests, we'll want to send in a bunch of ('verbatim', 'foo'). This
    class factors that out, so you can make the send value less verbose.

    Also, unless you write the docstring strangely, there will always be
    a blank line at the end of send; this class will automatically add
    ('verbatim', '') to the expect so you don't have to write it.

    Example::

        class TestThingAutoindexDoes(AutoindexTest):
            ""\"When it sees an include, it emits ('include', 'thing'):""\"
            send = ""\"\\
        include two
        ""\"
            expect = [
                    ('include', 'two'),
                    ('verbatim', 'line two'),
                ]
    """
    send = ''
    expect = []
    coroutine_under_test = autoindex
    def preprocess_send(self):
        for x in self.send.split("\n"):
            yield ('verbatim', x)
    def preprocess_expect(self):
        for x in self.expect:
            yield x
        yield ('verbatim', '')



class TestClassDefinition(AutoIndexTest):
    """Classes defined are indexed:"""
    send = """\
class foo::bar {
        some stuff
}
"""
    expect = [
            ('index_entry', 'class', 'foo::bar', 'defined'),
            ('label', 'class_foo::bar'),
            ('verbatim', 'class foo::bar {'),
            ('verbatim', '        some stuff'),
            ('verbatim', '}'),
        ]


class TestParameterizedClassDefinition(AutoIndexTest):
    """When classes are defined with parameters, only the name is indexed:"""
    send = """\
class foo::bar($param1, $param2) {
        some stuff
}
"""
    expect = [
            ('index_entry', 'class', 'foo::bar', 'defined'),
            ('label', 'class_foo::bar'),
            ('verbatim', 'class foo::bar($param1, $param2) {'),
            ('verbatim', '        some stuff'),
            ('verbatim', '}'),
        ]



class TestClassUseByInclude(AutoIndexTest):
    """Classes used by means of `include` are indexed:"""
    send = """\
    include foo_bar::baz
"""
    expect = [
            ('index_entry', 'class', 'foo_bar::baz'),
            ('verbatim', '    include foo_bar::baz'),
            ('margin_ref', 'class_foo_bar::baz'),
        ]

class TestClassUseByClassBracket(AutoIndexTest):
    """Classes used by means of ``class {...}``` are not yet supported:"""
    send = """\
class { 'foo::bar':
    bla
}
"""
    expect = [
            ('index_entry', 'class', 'foo::bar'),
            ('verbatim', "class { 'foo::bar':"),
            ('margin_ref', 'class_foo::bar'),
            ('verbatim', '    bla'),
            ('verbatim', '}'),
        ]


class TestDefinedResourceTypeDefinition(AutoIndexTest):
    """Defined resource types are indexed:"""
    send = """\
define foo_bar::baz($paramOne,
        $paramTwo) {
}
"""
    expect = [
            ('index_entry', 'define', 'foo_bar::baz', 'defined'),
            ('label', 'define_foo_bar::baz'),
            ('verbatim', 'define foo_bar::baz($paramOne,'),
            ('verbatim', '        $paramTwo) {'),
            ('verbatim', '}'),
        ]


class TestDefinedResourceTypeUse(AutoIndexTest):
    """Uses of defined resource types are indexed and noted:"""
    send = """\
class foo {
    bar_baz::bletch { "gack": }
}
"""
    expect = [
            ('index_entry', 'class', 'foo', 'defined'),
            ('label', 'class_foo'),
            ('verbatim', 'class foo {'),
            ('index_entry', 'define', 'bar_baz::bletch'),
            ('verbatim', '    bar_baz::bletch { "gack": }'),
            ('margin_ref', 'define_bar_baz::bletch'),
            ('verbatim', '}'),
        ]


class TestFileUseSameLine(AutoIndexTest):
    """Mentions of files are indexed:"""
    send = """\
file { "/foo/bar/baz":
    ...
}
"""
    expect = [
            ('index_entry', 'file', '/foo/bar/baz'),
            ('verbatim', 'file { "/foo/bar/baz":'),
            ('verbatim', '    ...'),
            ('verbatim', '}'),
        ]

class TestFileUseDifferentLine(AutoIndexTest):
    """Some file syntaxes are not yet supported:"""
    send = """\
file {
    "/foo/bar/baz":
        ...;
    "/bletch/quux/gark":
        ...;
}
"""
    expect = [
            ('verbatim', 'file {'),
            ('verbatim', '    "/foo/bar/baz":'),
            ('verbatim', '        ...;'),
            ('verbatim', '    "/bletch/quux/gark":'),
            ('verbatim', '        ...;'),
            ('verbatim', '}'),
        ]


if __name__ == '__main__':
    unittest.main()
