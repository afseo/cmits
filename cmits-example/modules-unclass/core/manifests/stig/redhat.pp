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
# \subsection{Under Red Hat}
#
# If core dumps are required, include this class to configure them in the
# fashion required by the SRG. If not, include \verb!core::no!.
#
# Our goal here is to protect core dumps as if they contain sensitive data,
# because they may. The SRG requires things about where they are stored, but
# RHEL6 is more advanced: it contains SOS and ABRT (Automatic Bug Reporting
# Tool), both of which can send relevant details of a crash to the vendor (Red
# Hat) or the upstream maintainer of a package. Both of these give the user a
# chance to vet the outgoing information, but that's still an unacceptable
# level of risk to the data. Accordingly, in order to keep the spirit of the
# SRG in an area where its letter does not speak, we secure these tools.
#
# ABRT sets the kernel's \verb!core_pattern! variable so that core dumps are
# sent to ABRT, and analyzed and written by that tool.
#
# If this policy is extended to other versions of RHEL, this section will need
# to be revisited.

class core::stig::redhat {
# The stock ABRT config file has sections that look like \verb![ Section ]!.
# This means that Augeas expressions for settings inside those sections contain
# spaces, and Augeas tends to think that spaces delimit parameters. So we need
# to go in and take out those spaces.
    exec { "sanify_abrt_conf_sections":
        command => "/bin/sed -i -e \
            's/^\\[ \\+\\(.*\\) \\+\\]/[\\1]/g' \
            /etc/abrt/abrt.conf",
        onlyif => "/bin/grep '^\\[ ' /etc/abrt/abrt.conf",
    }
# non-stock Augeas lens
    include augeas
    augeas {
# Remove vendor-supplied FTP and email addresses for SOS uploading, breaking
# this feature.
        "abrt_remove_sos_uploads":
            context => "/files/etc/sos.conf",
            changes => [
                "set ftp_upload_url ''",
                "set gpg_recipient ''",
            ];
# Don't activate SOS immediately when a crash occurs.
        "abrt_disable_sos":
            require => Exec['sanify_abrt_conf_sections'],
            context => "/files/etc/abrt/abrt.conf/Common",
            changes => "rm ActionsAndReporters[.='SOSreport']";
# Remove \verb!RHTSupport! plugin from the loop for each crash type.
        "abrt_logger_only":
            require => Exec['sanify_abrt_conf_sections'],
            context => "/files/etc/abrt/abrt.conf/\
AnalyzerActionsAndReporters",
            changes => [
                "set Kerneloops Logger",
                "set CCpp Logger",
                "set Python Logger",
            ];
    }

# \implements{unixsrg}{GEN003501,GEN003502,GEN003503,GEN003504} Control
# ownership and permissions for core-dump-related files written by the
# Automated Bug Reporting Tool (ABRT).
#
# ABRT uses \verb!/var/spool/abrt! for its core files; files may be uploaded
# into \verb!/var/spool/abrt-upload!, so it will be protected similarly.
# ABRT's directories must be owned by the abrt user, not root; this does not
# fulfill the letter of the SRG requirements, but it also does not violate
# their spirit.
    file {
        "/var/spool/abrt":
            owner => abrt, group => 0, mode => 0600,
            recurse => true, recurselimit => 2;
        "/var/spool/abrt-upload":
            owner => abrt, group => 0, mode => 0600,
            recurse => true, recurselimit => 2;
    }
# \implements{unixsrg}{GEN003505} Remove extended ACLs on ABRT directories.
    no_ext_acl {
        "/var/spool/abrt": recurse => true;
        "/var/spool/abrt-upload": recurse => true;
    }
}

# After all this, ABRT and SOS will not do anything rash automatically, but
# data from crashes will likely still be saved, can be read only by
# administrators, and can be sent on to vendors or upstream developers where
# necessary and appropriate.
