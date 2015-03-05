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
from __future__ import with_statement
"""Prepare the per-IAC output directories.

This means writing empty per-IAC sections, and copying written (special)
per-IAC sections into place.
"""

import os.path
from glob import glob
from shaney import ia_controls

def write_empty_sections(per_iac_empty_template, iac_output_dir):
    """Write an empty section for each possible IA control.

    This is so the section numbers in the per-IAC chapter will never change,
    even if the policy expands and fulfills more IA controls in the future.
    (This could happen as more areas of the host's configuration come under
    policy control, or as the policy begins to control hosts in other mission
    assurance categories or with other sensitivities.)
    """
    lines = file(per_iac_empty_template, 'rt').readlines()
    lines = [l for l in lines if not l.startswith('##')]
    template = ''.join(lines)
    for id, title in ia_controls.names.items():
        with file(os.path.join(iac_output_dir, id), 'w') as f:
            to_write = template.replace('${id}', id).replace('${title}', title)
            f.write(unicode(to_write).encode('UTF-8'))


def write_special_sections(per_iac_special_dir, write_the_iac_files):
    """Copy special per-IAC text to the per-IAC output directory.

    "Special" means that the IA control in question is easy to write a
    fixed section of prose about, and it's hard to programmatically
    derive prose about it. For these we copy files from the
    per_iac_special_dir to the per-IAC output directory.

    If something pertaining to an IA control is programmatically found
    after the special section is copied into place, the programmatic
    text will overwrite the special text.
    """
    take_credit_for = []
    for special in glob(os.path.join(per_iac_special_dir, '*')):
        basename = os.path.basename(special)
        if basename != 'README':
            for line in file(special):
                # basename is the name of a file named after an IA control
                write_the_iac_files.send((basename, ('toplevel', line)))
            take_credit_for.append(basename)
    return take_credit_for
