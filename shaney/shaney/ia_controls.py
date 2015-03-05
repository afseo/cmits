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
"""Information about DoDI 8500.2 IA controls.

names is a dictionary containing the names of all IA controls, for every
system profile (combination of mission assurance category and
sensitivity). ::

    >>> ia_controls.names['EBBD-3']
    'Boundary Defense'

for_system_profile is a dictionary whose keys are system profile names,
as written in the STIGs received from DISA in XCCDF format (e.g.
'MAC-3_Sensitive'). For each such key, the value is a tuple of all
identifiers for IA controls which apply to that system profile (one such
identifier may be 'COAS-1').

    >>> len(len(ia_controls.names)
    157
    >>> len(ia_controls.for_system_profile['MAC-3_Sensitive'])
    100
    >>> ia_controls.for_system_profile['MAC-3_Sensitive'][0]
    'COAS-1'

"""

try:
    from pkg_resources import resource_string, resource_listdir
    _files = lambda: resource_listdir('shaney', 'ia_controls_info')
    # resource_string uses only /, not os.path.sep
    _contents = lambda fn: resource_string('shaney',
                'ia_controls_info/' + fn)
except ImportError:
    # Don't have setuptools or other similar. Use __file__
    import os
    _iac_info_dir = os.path.join(
            os.path.dirname(__file__),
            'ia_controls_info')
    _files = lambda: os.listdir(_iac_info_dir)
    _contents = lambda fn: file(os.path.join(_iac_info_dir, fn)).read()

_all_colon_separated = _contents('names.txt')
# [:-1]: discard last item, which will be an empty string
_lines = _all_colon_separated.split('\n')[:-1]
# each line has exactly one colon, separating the IA control identifier
# and the IA control name
names = dict(x.strip().split(':') for x in _lines)

del _lines
del _all_colon_separated

for_system_profile = {}

for _fn in _files():
    if _fn.startswith('profile_') and _fn.endswith('.txt'):
        _profilename = _fn[len('profile_'):-len('.txt')]
        # [:-1]: discard empty string after last '\n'
        _iacs = tuple(_contents(_fn).split('\n')[:-1])
        for_system_profile[_profilename] = _iacs

del _fn
del _profilename
del _iacs
try:
    del _iac_info_dir
except NameError:
    pass
del _files
del _contents
