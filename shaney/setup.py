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
from setuptools import setup

setup(
        name='shaney',
        description='Deal with literate Puppet code',
        long_description="""\
Turn literate Puppet code inside out, and perform other feats.

Take Puppet code with comments containing LaTeX inputs, and produce
LaTeX inputs with verbatim sections containing the Puppet code. Also
produce automatic summaries of statements of compliance posture.
""",
        version='1.12',
        author='Jared Jennings',
        author_email='jared.jennings.ctr@us.af.mil',
        license='unlicensed',
        platforms='OS-independent',
        packages=['shaney', 'shaney.generators', 'shaney.sourapples'],
        entry_points = {
            'console_scripts': [
                'shaneyg = shaney.generators.main:main',
                'sourapples = shaney.sourapples.console_main:main',
                'sourapples_tk = shaney.sourapples.tk_main:main',
                'sourapples_clean = shaney.sourapples.clean:main',
            ],
        },
        include_package_data=True,
        )

