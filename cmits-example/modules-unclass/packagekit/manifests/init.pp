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
# \section{PackageKit}
#
# PackageKit helps normal users install packages. It's intended to enable
# security and bugfix updates on computers where there is no real
# administrator---like home desktops. In general, any environment where we are
# running Puppet is an environment with a real administrator, and where there
# are admins, users should not be making decisions about software updates.
#
# Some parts of PackageKit look useful: for example, its service pack
# functionality. Admins can use \verb!pkcon!, \verb!pkgenpack!, or
# \verb!gpk-application! to access these parts; meanwhile, users should not be
# bothered with anything relating to software packages.

class packagekit {
    include packagekit::no_icon
    include packagekit::admin_auth
    include packagekit::no_auto
    include packagekit::no_notify
}
