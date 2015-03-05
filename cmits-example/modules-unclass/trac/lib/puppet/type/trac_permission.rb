# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
require 'puppet'

Puppet::Type.newtype(:trac_permission) do
    @doc = <<-EOT
        Manage permissions in Trac instances.

        Permissions let some Trac users see different parts of a Trac instance
        than others. For example, users with the TRAC_ADMIN permission have the
        "Admin" tab at the top of every page; users without it do not. For
        users with TICKET_ADMIN, the "reporter" field of a ticket is an edit
        box; for users without it, the "reporter" field is a label, uneditable.

        The list of actions to which Trac can grant permission is fixed in the
        Trac code. Actions can be grouped into roles merely by granting
        permissions to a user who doesn't exist, e.g. "programmers," and then
        granting the action "programmers" to users that do exist.

        Example:
        
            trac_permission {
                'nonsense name 1':
                    instance => '/var/www/tracs/fnord',
                    subject => 'programmers',
                    action => ['TICKET_VIEW', 'WIKI_EDIT'];
                'nonsense name 2':
                    instance => '/var/www/tracs/fnord',
                    subject => 'jane',
                    action => 'programmers';
                'nonsense name 3':
                    instance => '/var/www/tracs/fnord',
                    subject => ['bob', 'joe', 'anonymous'],
                    action => ['TICKET_ADMIN', 'TRAC_ADMIN'],
                    ensure => absent;
            }
    EOT

    # Why is it this way? 
    #
    # Alternatives considered (the code presently follows #4):
    # 1. The name is the Trac instance; subject and action are parameters;
    #    ensure is a property.
    #    trac_permission { '/var/www/tracs/fnord':
    #       subject => ['bob', 'jane'],
    #       action => TRAC_ADMIN,
    #    }
    #    This makes it easy to grant one permission to many users in a Trac
    #    instance, and more obvious how to find the present configuration of an
    #    instance using `puppet resource`, if it were to work. But it means
    #    that all permissions relating to this Trac must be written solely in
    #    this resource; and what happens when Bob and Jane are to have
    #    different permissions from each other, and we also need to ensure that
    #    Jack does *not* have TRAC_ADMIN? This seems like trying to stuff the
    #    information that should go into multiple resources into one.
    # 
    # 2. The name is the instance:username. Action is a parameter. Ensure is a
    #    property.
    #    trac_permission { '/var/www/tracs/fnord:bob':
    #       action => TRAC_ADMIN,
    #    }
    #    This makes it easy to grant or revoke many permissions to/from one
    #    user; but it makes it harder to grant or revoke permissions from a
    #    list of users. The colon introduces some extra syntax over what is
    #    normally required. All permissions for this user must be written
    #    solely in this resource, which makes it hard to grant some and revoke
    #    others; this points toward action being a property, but that leads to 
    #    writing every permission of every user in the manifest, not just the
    #    ones that need to be changed. That has the feeling of mere
    #    transposition of the entire set of information from one syntax to
    #    another.
    #
    # 3. The name is the instance:username:action. Ensure is a property.
    #    trac_permission { '/var/www/tracs/fnord:bob:TRAC_ADMIN':
    #    }
    #    Now granting permissions in multiple places in the policy is easy (if
    #    it is even desirable). Lists of users and of actions are collapsed
    #    into a sea of single resources. More colons make the syntax even
    #    weirder. But only changes are written, not the whole table of
    #    permissions; that's good.
    #
    # 4. The name is not significant. Instance, subject and action are
    #    parameters; ensure is a property.
    #    trac_permission { 'barblezart':
    #       instance => '/var/www/tracs/fnord',
    #       user => ['bob', 'jane'],
    #       action => TRAC_ADMIN,
    #    }
    #    This makes it easy to grant and revoke lists of permissions to/from
    #    lists of users. There is no weird syntax. The only weird thing is that
    #    the name does not matter except to be unique. But, in this manifest,
    #    that's how exec and augeas resources tend to be written anyway.
    #
    # 5. The name is the username (subject). Instance and action are
    #    parameters; ensure is a property.
    #    trac_permission { 'bob':
    #       instance => '/var/www/tracs/fnord',
    #       action => TRAC_ADMIN,
    #    }
    #    This way, one resource specifies Bob's access across all Trac
    #    instances. But when collecting resources of this kind using `puppet
    #    resource`, we don't know what to write for the 'bob' resource until
    #    we've looked at all of the Trac instances on the system.

    ensurable do
        defaultvalues
        defaultto :present
    end

    newparam(:name) do
        desc "Not used. Set to anything you like."
    end

    newparam(:instance) do
        desc "The directory where the Trac instance is stored."
        isnamevar
        isrequired
        newvalues /^\/.*$/
    end

    newparam(:subject) do
        desc "The name of the user or group doing the action."
        isnamevar
        isrequired
        # For compatibility with Trac we should require that subject not be all
        # uppercase. But on the SBU, usernames will frequently be all
        # uppercase, and we'll have patched Trac to deal with this.
    end

    newparam(:action) do
        desc "The name(s) of the permission(s) to grant."
        isrequired
    end

    def self.title_patterns
        [
            [/^([^:]+):([^:]+):(.+)$/, [
                [ :instance, lambda {|x| x} ],
                [ :subject, lambda {|x| x} ],
                [ :action, lambda {|x| x} ]]],
            [/^.*$/, []]]
    end
end
