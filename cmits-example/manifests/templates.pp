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
# \section{templates.pp}
# \label{templates}
#
# Here are the primary units of functionality needed to configure nodes within
# our administration. Classes referred to with the \verb!include! directive
# implement smaller units of policy and are covered in the ensuing sections of
# \S\ref{Policy}.
#

class unix_stig_compliance_base {
    include aide
    include ssh::stig
    include stig_misc
    include user::valid
    include user::unnecessary
    include gnome-screensaver::stig
    include shell::stig
    include pam::rhosts
    include at::stig
    include kdump::no
    include network::stig
    include ftp::no
    include pki::ca_certs::system_nss
    include ldap::stig
    include disable_ctrlaltdel
    include snmp::no
    include network::no_bluetooth
}


class example_org_workstation
    include automount
    class { 'gdm::logo':
        source => 'puppet:///gdm/logo/example-org',
    }
    automount::mount { 'apps': from => 'example-data:/vol/apps' }
    class { 'grub::password':
        md5_password => 'ddce269a1e3d054cae349621c198dd52',
    }
}

