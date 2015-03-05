#!/usr/bin/python
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
import sys
import os
import unicodedata
import codecs, locale

class Sectioner(object):
    """Make section hierarchies corresponding to directories."""
    def __init__(self):
        self.section = None
        self.subsection = None
    def ensure_correct_section_g(self, elements):
        section = elements[0]
        subsection = os.path.join(*elements[1:])
        if section != self.section:
            yield "\\clearpage"
            yield "\\section{ %s/ }" % latex_sanitize(section)
            yield "\\label{attendant_%s}" % section
            yield "For the policy that requires files in this section,"
            yield "see \\ref{module_%s}." % section
            self.section = section
        if subsection != self.subsection:
            yield "\\subsection{ %s }" % latex_sanitize(subsection)
            self.subsection = subsection


def latex_sanitize(s):
    return s.replace('\\', '/').replace('_', '\\_')

def widthsplit(s, width):
    """Split a string into pieces width chars long, plus one remainder."""
    r = []
    while s:
        r.append(s[:width])
        s = s[width:]
    return r

def bracket_escape(e):
    ch = e.object[e.start]
    try:
        name = ' ' + unicodedata.name(ch)
    except KeyError:
        name = ''
    escape = repr(ch).strip("u'")
    replacement = u"[UNICODE %s%s]" % (escape, name)
    return (replacement, e.end)
codecs.register_error("bracket_escape", bracket_escape)


PRINTABLE_CHARS = ''.join(chr(i) for i in range(32, 127))

def is_empty(filename):
    return os.path.getsize(filename) == 0

def looks_texty(filename):
    """Determine whether a file looks like English text or not.
    """
    with file(filename, 'rb') as f:
        sample = f.read(512)
        # remove printable chars, leaving weird ones
        weird = sample.translate(None, PRINTABLE_CHARS)
        # less than 10% non-ASCII printable chars
        return (len(weird) < 51)

def prepare_for_tex_output(output):
    # Our output will be read by TeX, which is incapable of dealing with
    # multibyte character encodings. See
    # http://tex.stackexchange.com/questions/6982/no-simple-utf8-support-in-latex
    # (RHEL6 has XeTeX and XeLaTeX but RHEL5 does not, so let's not
    # depend on it just yet.)
    return codecs.getwriter("ISO8859-1")(output)

class AttendantFileGatherer(object):
    """Create a LaTeX file that will include many files verbatim.

    Expected parameters are all of the files to include. The parameters will
    be sorted.

    """

    def __init__(self, strip_leading_dirs=2, line_width=75,
            assumed_path_element='files'):
        """Parameters:

        strip_leading_dirs is a number of directories to discard from
        filenames before showing them. For example, a file
        ../modules/foo will be shown as foo if strip_leading_dirs is 2.

        line_width is the maximum number of characters per output line.
        Default is 75.

        assumed_path_element is a next-to-last path element to remove.
        For example, Puppet has a hierarchy like
        modules/<modulename>/files/<file>. We want to get rid of
        'files', because when you use Puppet's source metaparameter to
        talk about a file in the manifest, you say source =>
        puppet:///modules/<modulename>/<file>, so when you look up the
        file in the attendant files section of the unified policy
        document, you want to see its pathname without the 'files'
        directory in the middle. Other values you may want to set for
        this parameter may be 'templates'.
        """

        self.discard = strip_leading_dirs
        self.line_width = line_width
        self.assumed_path_element = assumed_path_element

        self.sectioner = Sectioner()


    def utf8text_g(self, filename, showname):
        yield "{\\footnotesize"
        yield "\\begin{verbatim}"
        f = file(filename)
        linenumber = 1
        for l in f:
            # Assume input is UTF-8; assume output is ISO8859-1; see XeTeX
            # discussion below. We must reencode the line because the
            # bracket-escape will require more characters than any original
            # UTF-8 character did, so then we may need to wrap the line.
            l = l.decode('UTF-8').encode("ISO8859-1", "bracket_escape")
            # Wrapping happens in the ISO8859-1 encoding
            out = '[WRAP]\n'.join(widthsplit(l.rstrip('\n'), self.line_width))
            yield out
            linenumber += 1
        yield "\\end{verbatim}"
        yield "}"
        yield ""

    def empty_g(self, filename, showname):
        yield "The file {\\tt %s} is empty." % showname
        yield ""

    def non_human_readable_g(self, filename, showname):
        # Sorry, non-english speakers, I don't mean to belittle your
        # language as unreadable.
        yield "The file {\\tt %s} appears not to be " \
            "human-readable. It is not included here." % showname
        yield ""

    def operate_on_g(self, filenames):
  
        for f in filenames:
            elements = f.split(os.path.sep)[self.discard:]
            if elements[1] == self.assumed_path_element:
                elements.pop(1)
            for x in self.sectioner.ensure_correct_section_g(elements):
                yield x
            showname = latex_sanitize(os.path.join(*elements))
            if is_empty(f):
                for x in self.empty_g(f, showname): yield x
            else:
                if looks_texty(f):
                    for x in self.utf8text_g(f, showname): yield x
                else:
                    for x in self.non_human_readable_g(f, showname): yield x


if __name__ == '__main__':
    sys.argv.pop(0) # the first one will be the script name
    sys.argv.sort()
    for line in AttendantFileGatherer().operate_on_g(sys.argv):
        print line
