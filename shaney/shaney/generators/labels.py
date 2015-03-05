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
import os.path
import logging

def sanitize_label(l):
    """You can't write a backslash in a label. Fix.

    We use filenames to construct labels. Under windows, those filenames
    contain backslashes. But backslashes are significant to LaTeX, even
    inside label names. So we neutralize them.
    """
    return l.replace('\\', '/')

def labels_for_files(dirs_to_strip):
    """Emits a label when a new file is detected.

    Input: tuples of these forms:
        ('new_file', filename)
        (any other string, anything)
    Output: tuples of these forms:
        ('label', most of filename)
    Does not pass messages through.
    """
    def coro(target):
        log = logging.getLogger('lff')
        while True:
            value = (yield)
            if value[0] == 'new_file':
                filename = value[1]
                pieces = filename.split(os.path.sep)[dirs_to_strip:]
                name = os.path.sep.join(pieces)
                target.send( ('label', sanitize_label(name)) )
            else:
                pass
    return coro

def labels_for_modules(dirs_to_strip):
    """Emits a label when a new Puppet module is detected.

    Input: tuples of these forms:
        ('new_file', filename)
        (any other string, anything)
    Output: tuples of these forms:
        ('label', module name)
    Does not pass messages through.
    """
    def coro(target):
        log = logging.getLogger('lfm')
        while True:
            value = (yield)
            if value[0] == 'new_file':
                filename = value[1]
                pieces = filename.split(os.path.sep)[dirs_to_strip:]
                if pieces[0] == 'modules' or \
                        pieces[0].startswith('modules-'):
                    if pieces[-2:] == ['manifests', 'init.pp']:
                        target.send( ('label', 'module_' + pieces[1]) )
                    else:
                        # this is a file belonging to a submodule, not a
                        # main module
                        pass
                else:
                    # this Puppet source does not belong to a module (e.g.
                    # it is in the manifests directory)
                    pass
            else:
                # message we don't care about
                pass
    return coro

def buffer_labels_till_first_latex_line(target):
    """
    The first LaTeX syntax line in a file is likely a section
    directive. If we emit the label before that directive, the
    label will point at the previous section, not this section.
    So we delay emitting the label until after.

    Input: tuples of these forms:
        ('new_file', filename)
        ('label', string)
        ('comment', line)
        ('toplevel', line)
        (any other string, anything)
    Output: tuples of any of the first four forms above.

    Passes messages through.
    """
    file_just_began = True
    preserved_labels = []
    log = logging.getLogger('bltfll')
    while True:
        value = (yield)
        if value[0] == 'new_file':
            file_just_began = True
            target.send(value)
        elif value[0] == 'label':
            if file_just_began:
                preserved_labels.append(value)
            else:
                target.send(value)
        elif value[0] == 'toplevel':
            target.send(value)
            line = value[1]
            # now, having sent that...
            if file_just_began:
                if line.strip() != '':
                    file_just_began = False
                    for l in preserved_labels:
                        target.send(l)
                    preserved_labels = []
        elif value[0] == 'verbatim':
            target.send(value)
            if file_just_began:
                # Welp, it looks like there's no LaTeX code at the beginning
                # of this file. No LaTeX, no section head. Go ahead and emit
                # the labels.
                file_just_began = False
                for l in preserved_labels:
                    target.send(l)
                preserved_labels = []
        else:
            target.send(value)


