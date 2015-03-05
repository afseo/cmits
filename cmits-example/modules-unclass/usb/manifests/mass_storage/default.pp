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
# \subsection{Use default USB mass storage permissions}
#
# Let the console user use USB mass storage, subject to defaults. Whenever the
# USB mass storage policy for a node or class is made less restrictive, you
# should replace the \verb!include usb::mass_storage::bla! class with an
# include for this class in that context.
class usb::mass_storage::default {
    file { "/etc/polkit-1/localauthority/90-mandatory.d/\
50-mil.af.eglin.afseo.admin-udisks.pkla":
        ensure => absent,
    }
}
