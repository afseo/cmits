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
from getopt import getopt
import logging

from shaney.xccdfmeaning import XCCDFMeaning
from shaney.mvs import MarkVShaney

def usage():
    print >> sys.stderr, """

Usage: %(progname)s [-p n]
                    ../manifests/file1.pp [/other/place/file2.pp ...]

Takes as input one or more Puppet files with LaTeX written in their comments,
and puts out (uncommented) LaTeX code with the Puppet code inserted as verbatim
sections.

For each file, a label is generated with its filename; for example, when
file1.pp is parsed, the output will contain first "\label{file1.pp}", then its
contents. If -p is given, n path elements are stripped off each filename before
the label is created; for example, %(progname)s -p 1 a/b/file1.pp will result in 
a label of "\label{b/file1.pp}".

For each IA control, a file in a directory named per-iac-output is created,
which contains the pieces of the policy that implement that IA control.

""" % {'progname': sys.argv[0]}


def parse_args(argv):
    unix_srg_xccdf_file = '../xccdfs/U_OS-SRG-UNIX_V1R1-xccdf.xml'
    profile_id = "MAC-3_Sensitive"
    policy_output = sys.stdout
    nToStrip = 0
    loglevel = logging.ERROR
    iac_output_dir = "per-iac-output"
    exec_summary_output = None
    per_iac_special_dir = None
    per_iac_output_dir = 'per-iac-output'
    per_iac_empty_template = 'per-iac-empty.tex.tmpl'

    ovpairs, rest = getopt(sys.argv[1:], 'p:d', ['per-iac-to=',
            'exec-summary-to=', 'per-iac-special='])
    for o, v in ovpairs:
        if o == '-p':
            nToStrip = int(v)
        if o == '-d':
            loglevel = logging.DEBUG
        if o == '-o':
            policy_output = file(v, 'w')
        if o == '--per-iac-to':
            per_iac_output_dir = v
        if o == '--exec-summary-to':
            exec_summary_output = file(v, 'w')
        if o == '--per-iac-special':
            per_iac_special_dir = v
    if len(rest) < 2:
        usage()
        sys.exit(1)
    latex_files = [x for x in rest if x.endswith('.tex')]
    puppet_files = [x for x in rest if x.endswith('.pp')]
    checklists = {
            'unixsrg': XCCDFMeaning(unix_srg_xccdf_file, profile_id),
    }

    mvs = MarkVShaney(nToStrip, latex_files, puppet_files, checklists,
            per_iac_special_dir, per_iac_empty_template, policy_output,
            exec_summary_output, per_iac_output_dir)

    return (mvs, loglevel)

def main():
    theMvs, loglevel = parse_args(sys.argv[1:])
    logging.basicConfig(stream=sys.stderr, level=loglevel)
    logging.info('logging began!')
    # "---One that looks nice... And not too expensive. Now, GO!"
    theMvs.now_go()
