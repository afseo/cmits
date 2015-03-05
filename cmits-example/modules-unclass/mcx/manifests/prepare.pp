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
# \subsection{Prepare computer object}
#
# Make an object for the computer so that we can set MCX settings on it. See
# \url{http://projects.puppetlabs.com/issues/5079} for why we would not just
# use \verb!/Computers/localhost!.

class mcx::prepare {
# This exec resource is lifted from 
# \url{http://flybyproduct.carlcaum.com/2010/03/managing-mcx-with-puppet-on-snow.html}.
# But we use the \verb!-F! switch to \verb!grep! so that it will treat the FQDN
# as a literal string to search for, not a regular expression. This may never
# matter but it is more correct.
    exec { "System in Local Directory":
        path => ['/bin', '/usr/bin'],
        command => "dscl localhost -create \
                    /Local/Default/Computers/$::fqdn \
                    ENetAddress $::macaddress_en0 \
                    RealName $::fqdn \
                    RecordName $::fqdn",
        unless => "dscl localhost -list \
                    /Local/Default/Computers | \
                    grep -F $::fqdn",
    }
}
