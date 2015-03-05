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
from shaney.generators import pipe
from shaney.generators.match import tagged_match

def verbatim_match(regex):
    """Do something when a regex matches a line of Puppet syntax."""
    return tagged_match('verbatim', regex)

# A line with "class mumble" in it is a class definition.  But a line
# with "class {" is a class use. We're dealing only with definitions
# here, so reject the latter.
@verbatim_match(r"class[\s]*([^(\s{]+)")
def class_definition(m, value, target):
    cl = m[0]
    target.send( ('index_entry', 'class', cl, 'defined') )
    target.send( ('label', 'class_' + cl) )
    target.send(value)

# Making margin references happen immediately *after* the line they
# pertain to in the LaTeX source appears to make them line up right next
# to the line in the LaTeX output. So margin refs must be emitted after
# the line.

# A line with "include bla" in it is a class use. We had [\S]+ here for
# the identifier, but it matched '=>'. Not so good.
# (This will not catch class { ... } statements.)
@verbatim_match(r"^[\s]*include[\s]+([\w:-]+)")
def class_include(m, value, target):
    cl = m[0]
    target.send( ('index_entry', 'class', cl) )
    target.send(value)
    target.send( ('margin_ref', 'class_' + cl) )


# A line with "class { 'foo::bar':" in it is a class use.
# This will not catch class { ... } statements where the class name is
# on a different line.
#
# Also it will not catch class { ... } statements where the class name
# is not in quotes. But Puppet coding style says this case is gauche.
@verbatim_match(r'''class[\s]*{[\s]*(["'])([^\1]*)\1''')
def class_bracket_quoted_include(m, value, target):
    cl = m[0][1]
    target.send( ('index_entry', 'class', cl) )
    target.send(value)
    target.send( ('margin_ref', 'class_' + cl) )


# A line with "define foo" in it is a defined resource type definition.
@verbatim_match(r"define[\s]*([^\s(]+)")
def define_definition(m, value, target):
    d = m[0]
    target.send( ('index_entry', 'define', d, 'defined') )
    target.send( ('label', 'define_' + d) )
    target.send(value)


# A line with "something::anotherthing[::morethings] {" is a defined
# resource type use. This will not catch defines which don't have '::'
# in their names; but it will also not catch built-in resource types.
@verbatim_match(r"^[\s]*([\w]+(::[\w]+)+)[\s]*{")
def define_use(m, value, target):
    d = m[0][0]
    target.send( ('index_entry', 'define', d) )
    target.send(value)
    target.send( ('margin_ref', 'define_' + d) )


# A line with 'file { "bafbwelwfbew"' is a file use. This will not catch
# all used files.
@verbatim_match(r'''file[\s]*{[\s]*(["'])([^\1]*)\1''')
def file_use(m, value, target):
    filename = m[0][1]
    target.send( ('index_entry', 'file', filename) )
    target.send(value)


def autoindex(target):
    all = [
        class_definition,
        class_include,
        class_bracket_quoted_include,
        define_definition,
        define_use,
        file_use,
    ]
    return pipe(*(all + [target]))
