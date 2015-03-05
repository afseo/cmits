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
# \subsection{Custom YUM repository on Vagrant machines}
#
# On a proper network we may have a Red Hat Satellite server, but on a Vagrant
# host we may not have any networking, or may not be on the same network as
# such a server. Installation of most custom packages should be avoided under
# Vagrant, but some cannot be avoided. This class allows for custom packages
# distributed with the Vagrant machine to be made available to the virtual
# machine.
#
# Virtual machines set up with Vagrant are not secure in a networking sense:
# they have a fixed default root password, a default user with a fixed default
# password having sudo access, fixed insecure ssh keys, etc. In line with these
# decisions, we won't perform GPG signature checks on the RPMs in the custom
# repository, because the provenance of these packages is already exactly as
# secure as the provenance of the Puppet policy applied at install time: any
# attacker who could pervert a custom package could just change the Puppet
# policy. And the virtual machine built from these things is ephemeral and
# untrusted anyway.

class yum::vagrant() {
    yumrepo { "vagrant":
        name => "vagrant",
        baseurl => "file:///vagrant/custom-packages",
        enabled => 1,
        gpgcheck => 0,
    }
}
