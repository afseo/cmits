# % --- BEGIN DISCLAIMER ---
# % Those who use this do so at their own risk;
# % AFSEO does not provide maintenance nor support.
# % --- END DISCLAIMER ---
# % --- BEGIN AFSEO_DATA_RIGHTS ---
# % This is a work of the U.S. Government and is placed
# % into the public domain in accordance with 17 USC Sec.
# % 105. Those who redistribute or derive from this work
# % are requested to include a reference to the original,
# % at <https://github.com/afseo/cmits>, for example by
# % including this notice in its entirety in derived works.
# % --- END AFSEO_DATA_RIGHTS ---
# \subsection{For RHEL6}
#
# RHEL6 comes with Python 2.6.6, a fine version of Python. It just needs the
# setuptools, which are also (finally!) part of the distro.

class python::rhel6 {
    package {
        "python":
            ensure => present;
        "python-setuptools":
            ensure => present;
    }
}
