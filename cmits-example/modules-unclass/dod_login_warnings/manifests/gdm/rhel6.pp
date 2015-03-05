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
# \subsubsection{Under RHEL6}
#
# In RHEL6, banner functionality is inside gdm.

class dod_login_warnings::gdm::rhel6 {
    $agsg = '/apps/gdm/simple-greeter'
    gconf { "$agsg/banner_message_enable":
        config_source => '/var/lib/gdm/.gconf',
        type => bool,
        value => true,
    }
    gconf { "$agsg/banner_message_text":
        config_source => '/var/lib/gdm/.gconf',
        type => string,
        value => template('dod_login_warnings/paragraphs'),
    }

# All those settings probably created root-owned, solely-root-readable files in
# gdm's home directory. We need to let the gdm user read those files.
    file { '/var/lib/gdm/.gconf':
        owner => gdm, group => gdm,
        recurse => true, recurselimit => 5,
    }
}
