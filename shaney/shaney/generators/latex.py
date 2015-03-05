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

def lines_to_toplevel(target):
    while True:
        x = (yield)
        if x[0] == 'line':
            target.send( ('toplevel',) + x[1:] )

# outside class so we can write escape(foo) instead of self.escape(foo).
# terser.
def escape(text):
    return text.replace('_', '\\_').replace('$', '\\$')

class LatexEmitter(object):
    """Emit LaTeX syntax.

    Expects a stream of messages named the same as its methods. Note
    that ("toplevel", "foo") means foo is to be output as LaTeX input,
    and ("verbatim", "foo") means foo is to be output inside a verbatim
    block of some sort. In other words, "toplevel" is defined here with
    respect to LaTeX input, not Puppet source code.
    """

    TOPLEVEL = 1
    VERBATIM = 2

    TRANSITIONS = {
            (TOPLEVEL, VERBATIM): "\\begin{tightverbatim}\n",
            (VERBATIM, TOPLEVEL): "\\end{tightverbatim}\n",
    }

    INDEX_ENTRY = "\\index{%(index)s}{%(item)s%(subtext)s}\n"
    MARGIN_REF = "\\marginpar{\\S\\ref{%(label)s}}\n"
    LABEL = "\\label{%(label)s}\n"
    IMPLEMENTS = "\\implements{%(document)s}{%(requirements)s}\n"
    EXCERPT_FROM = "\n\\vskip 1\\baselineskip{\\em From~\\S\\ref{%(label)s}\
                       (\\nameref{%(label)s}):}\n\n"
    SECTION = "\\section{%(name)s}\n\\label{%(label)s}\n"
    PARAGRAPH = "\n"

    BEGIN_EXEC_SUMMARY = "\n\\begin{executivesummary}\n"
    END_EXEC_SUMMARY = "\n\\end{executivesummary}\n"
    EXEC_SUMMARY_IA_CONTROL = "\\executivesummaryiacontrol" \
            "{%(id)s}{%(title)s}\n"

    def __init__(self, name):
        self.state = self.TOPLEVEL
        self.log = logging.getLogger('LatexEmitter ' + name)

    def __call__(self, target):
        # avoid passing target about among methods; that's why we have
        # self
        self.target = target
        try:
            while True:
                value = (yield)
                # try to deal with value using a method
                try:
                    meth = getattr(self, value[0])
                except AttributeError, e:
                    # must not be for us
                    pass
                else:
                    meth(*value[1:])
        except GeneratorExit:
            self.end()

    def _ensure(self, state):
        oldstate = self.state
        if self.state != state:
            transition = self.TRANSITIONS[self.state, state]
            self.target.send(transition)
            self.state = state
        return oldstate


    def verbatim(self, text):
        # avoid the scenario where we drop into a verbatim environment
        # between two toplevel lines just to emit a newline
        if text.strip() != '':
            self._ensure(self.VERBATIM)
        self.target.send(text)

    def toplevel(self, text):
        self._ensure(self.TOPLEVEL)
        self.target.send(text)

    def end(self):
        self._ensure(self.TOPLEVEL)

    def index_entry(self, index, item, subtext=''):
        if subtext != '':
            subtext = '!' + subtext
        self.toplevel(self.INDEX_ENTRY % {
            'index': index,
            'item': escape(item),
            'subtext': subtext})

    def margin_ref(self, label):
        self.toplevel(self.MARGIN_REF % {'label': label})

    def label(self, label):
        self.toplevel(self.LABEL % {'label': label})

    def implements(self, document, requirements, derived):
        # if the requirement is not derived, it is already written in
        # the text of the document! we don't want to duplicate it.
        if derived:
            self.toplevel(self.IMPLEMENTS % {'document': document,
                'requirements': ','.join(requirements)})

    def excerpt_from(self, label):
        self.toplevel(self.EXCERPT_FROM % {'label': label})

    def section(self, name, label=None):
        if label is None:
            label = name
        self.toplevel(self.SECTION % {'name': name, 'label': label})

    def paragraph(self):
        self.toplevel(self.PARAGRAPH)

    def begin_execsummary(self):
        self.toplevel(self.BEGIN_EXEC_SUMMARY)

    def end_execsummary(self):
        self.toplevel(self.END_EXEC_SUMMARY)

    def execsummary_iacontrol(self, id, title):
        self.toplevel(self.EXEC_SUMMARY_IA_CONTROL % {'id': id, 'title':
            title})
