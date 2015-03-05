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
# \subsubsection{Set proxy autoconfiguration URL in gconf}

class proxy::pac::gconf($url) {

# Set the system proxy settings for everyone mandatorily.
    gconf { '/system/proxy/autoconfig_url':
        config_source => 'mandatory',
        type => string,
        value => $url,
    }
    gconf { '/system/proxy/mode':
        config_source => 'mandatory',
        type => string,
        value => 'auto',
    }
}
