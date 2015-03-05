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
# \subsection{Restrict network changes to admins}
#
# \implements{unixsrg}{GEN003581} Don't let users configure network interfaces:
# require authentication of an administrator to do this.
#
# \emph{N.B.} This will cause trouble on any host which may change networks in
# the normal course of duty---like a laptop.

class networkmanager::admin_auth {
    case $osfamily {
        RedHat: {
            case $operatingsystemrelease {

# RHEL6 comes with NetworkManager, and it works and lets users do things to
# configure the network unless it's configured otherwise. Here we configure it
# to require admin authentication for any changes.
                /^6\..*/: {

# Get rid of the pre-\verb!policykit::rule! file.
                    file {
"/etc/polkit-1/localauthority/90-mandatory.d/\
50-mil.af.eglin.afseo.admin-network.pkla":
                        ensure => absent,
                    }

                    policykit::rule { 'admin-auth-network':
                        description =>
'only admins can change network settings',
                        identity => '*',
                        action =>
"org.freedesktop.NetworkManager.*;\
org.freedesktop.network-manager-settings.*",
                    }
                }

# While RHEL5 comes with NetworkManager, it appears that it doesn't come with
# PolicyKit, and it also doesn't appear that you can do anything with the
# network settings without being an admin, as required.
                /^5\..*/: {}

                default: { unimplemented() }
            }
        }
# % FIXME: Where does Darwin comply with GEN003581?
# Darwin doesn't have NetworkManager.
        Darwin: {}
        default: { unimplemented() }
    }
}
