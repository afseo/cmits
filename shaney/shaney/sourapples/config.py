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
from os import mkdir, getenv
import os.path
import logging
import subprocess
from ConfigParser import SafeConfigParser

try:
    import pkg_resources
except ImportError:
    pass

from shaney.xccdfmeaning import XCCDFMeaning
from shaney.mvs import MarkVShaney

from shaney.sourapples.attendant import AttendantFileGatherer
from shaney.sourapples import find
from shaney.sourapples.sort_manifests import puppet_key
from shaney.sourapples.run_subprocess import make_run_and_log_if_error

def _get_system_executable_path():
    return getenv('PATH').split(os.path.pathsep)

# http://wiki.python.org/moin/PythonDecoratorLibrary#Alternate_memoize_as_dict_subclass
class memoize(dict):
    def __init__(self, func):
        self.func = func
    def __call__(self, *args):
        return self[args]
    def __missing__(self, key):
        result = self[key] = self.func(*key)
        return result

class SourApplesConfig(SafeConfigParser):
    def __init__(self):
        SafeConfigParser.__init__(self)
        try:
            default_config = pkg_resources.resource_stream(
                    'shaney.sourapples', 'defaults.ini')
        except NameError:
            # the import of pkg_resources must have failed.
            default_config = file(os.path.join(
                os.path.dirname(__file__), 'defaults.ini'))
        self.readfp(default_config)
        self.read(['make_config.ini'])

    @property
    @memoize
    def meanings(self):
        log = logging.getLogger('get_meanings')
        meanings = {}
        for section in self.sections():
            if section.startswith('checklist.'):
                name = section[len('checklist.'):]
                log.info('using checklist %s', name)
                fn = self.get(section, 'xccdf_file')
                profile_id = self.get(section, 'profile_id')
                meaning = XCCDFMeaning(fn, profile_id)
                meanings[name] = meaning
        return meanings

    @property
    @memoize
    def markvshaney(self):
        nToStrip = self.getint('policy', 'strip_leading_dirs')
        per_iac_special_dir = self.get('per_iac', 'special_dir')
        per_iac_empty_template = self.get('per_iac', 'empty_template')
        per_iac_output_dir = self.get('per_iac', 'output_dir')
        if not os.path.exists(per_iac_output_dir):
            mkdir(per_iac_output_dir)
        policy_output = file(self.get('policy', 'output_file'),
                'w')
        exec_summary_output = file(self.get('exec_summary',
            'output_file'), 'w')
        mvs = MarkVShaney(nToStrip, self.written_latex_files,
                self.puppet_files, self.meanings, per_iac_special_dir,
                per_iac_empty_template, policy_output,
                exec_summary_output, per_iac_output_dir)
        return mvs

    @property
    @memoize
    def attendant_file_gatherer(self):
        strip_leading_dirs = self.getint('attendant_files',
                'strip_leading_dirs')
        line_width = self.getint('attendant_files', 'line_width')
        afg = AttendantFileGatherer(strip_leading_dirs, line_width,
                'files')
        return afg

    @property
    @memoize
    def attendant_template_gatherer(self):
        strip_leading_dirs = self.getint('attendant_templates',
                'strip_leading_dirs')
        line_width = self.getint('attendant_templates', 'line_width')
        atg = AttendantFileGatherer(strip_leading_dirs, line_width,
                'templates')
        return atg

    @property
    @memoize
    def walker(self):
        ignore_directories = self.get('main',
                'ignore_directories').split('\n')
        return find.make_walk_and_prune(ignore_directories)

    def _get_file_list(self, file_type_description,
            config_section, find_function, **kwargs):
        log = logging.getLogger('_get_file_list')
        log.info('finding %s files', file_type_description)
        locations = self.get(config_section, 'locations').split('\n')
        all_files = []
        for l in locations:
            log.debug(' - looking under %r', l)
            all_files.extend(find_function(l, self.walker,
                *kwargs.get('additional_find_args', [])))
        log.info('%7d %s files', len(all_files), file_type_description)
        return sorted(all_files, key=kwargs.get('key', None))

    @property
    @memoize
    def written_latex_files(self):
        return self._get_file_list('LaTeX', 'latex_documentation',
                find.latex_files_under)

    @property
    @memoize
    def puppet_files(self):
        return self._get_file_list('Puppet', 'puppet_files',
                find.puppet_manifests_under, key=puppet_key)

    @property
    @memoize
    def attendant_files(self):
        return self._get_file_list('attendant', 'puppet_files',
                find.attendant_files_under,
                additional_find_args=['files'])

    @property
    @memoize
    def attendant_templates(self):
        return self._get_file_list('template', 'puppet_files',
                find.attendant_files_under,
                additional_find_args=['templates'])

    def _seek_latex_executable(self, name):
        configured = self.get('latex_executables', 'locations').split('\n')
        system_path = _get_system_executable_path()
        for loc in (configured + system_path):
            for suffix in ('', '.exe'):
                putative_executable = os.path.join(loc, name + suffix)
                if os.path.exists(putative_executable):
                    return putative_executable

    @property
    @memoize
    def indices(self):
        builtin = filter(None, self.get('indices', 'builtin').split('\n'))
        extra = filter(None, self.get('indices', 'extra').split('\n'))
        return builtin + extra

    def make_latex_function(self, name):
        return make_run_and_log_if_error(
                self._seek_latex_executable(name))


