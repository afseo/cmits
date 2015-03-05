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
# \subsection{Satellite authentication using PAM}
#
# This is in direct accordance with section 8.10 of the RHN Satellite
# Installation Guide \cite{rhn-satellite-installation}.
#
# To achieve Active Directory authentication, obtain and install a PAM
# module on the Satellite server. Centrify works at AFSEO; SSS (part
# of RHEL) may work for this purpose; other products are also
# available.

class rhn_satellite::pam {

# In order to ``create a PAM service file for RHN Satellite'' and ``edit the
# file with the following information: [...],'' include one of the ensuing
# classes. The \verb!sss! class does exactly what the Installation Guide says
# to.
#
# ``Instruct the satellite to use the PAM service file...'' \verb!rhn.conf! is
# a Java properties file.
    augeas { 'rhn_satellite_use_pam':
        require => Augeas['rhn_satellite_pam_d'],
        context => '/files/etc/rhn/rhn.conf',
        changes => 'set pam_auth_service rhn-satellite',
# ``Restart the service to pick up the changes.''
        notify => Exec['rhn_satellite_restart'],
    }
}
