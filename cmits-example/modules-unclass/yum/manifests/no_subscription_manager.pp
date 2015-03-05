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
# \subsection{Turn off the Subscription Manager}
#
# Red Hat has moved to certificate-based subscriptions, using the Subscription
# Manager. But RHN Satellite 5.4.1 does not use these. But the plugin for
# certificate-based management is enabled by default. So since we don't have
# the certificates, every time Yum runs, that plugin complains that this system
# isn't subscribed. This class fixes that.

class yum::no_subscription_manager {
    augeas { 'disable_subscription_manager':
        context => "/files/etc/yum/pluginconf.d/\
subscription-manager.conf",
        changes => "set main/enabled 0",
    }
}
        
