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
# \section{NTP}
# \label{ntp}
#
# Configure the Network Time Protocol (NTP) service.
#
# \implements{unixsrg}{GEN000241} On all networks where timeservers exist,
# use \verb!ntpd! to keep continuous synchronization with the timeservers.
#
# Here is some background regarding NTP implementation interoperability as it
# relates to cryptographic authentication of time data:
#
# According to \cite{ms-sntp}, \S 1, time services on Windows support a subset
# of NTPv3 (\cite{rfc1305}), not NTPv4 (\cite{rfc5905}, \cite{rfc5906}), and \S
# 3.2.5.1 says, ``[T]he authentication mechanism defined in RFC 1305 Appendix
# C.1 is not supported.'' This means that Windows time services support neither
# the symmetric key authentication of NTPv3 nor the Autokey of NTPv4 as
# cryptographic means of authenticating time data, but only support the
# Microsoft-proprietary means of time data authentication within the context of
# an Active Directory domain. These proprietary extensions to NTP are not
# supported by the NTP software used in RHEL 5 and 6, which is the reference
# implementation of NTPv4 from the University of Delaware.

class ntp {
    include "ntp::${::osfamily}"
}
