
Example CMITS policy
--------------------

Herein are directions written to be read by the Puppet IT automation tool.
Here are also procedures for humans to read and carry out. Annotations written
throughout convey which requirements led to the writing of each bit. Scripts
herein generate a PDF file containing a `unified policy document` with all this
information in it, and generate reports on the compliance status of the policy.

Since this is an example, it's short on human procedures, and not entirely
complete. To make your own complete policy, read through the modules (you may
want to build a PDF to read; see unified-policy-document/README.txt), see how
the modules address compliance, choose a compliance posture, and make classes
that include the appropriate classes from each module. Then write node
definitions that configure each host appropriately. The ``manifests/*.pp``
files contain a start.


Using the policy with Puppet
----------------------------

The directory structure here is suitable to be dropped into /etc/puppet on a
Puppet master server. See the Puppet documentation for how to set one of these
up. The *.conf files are runtime configuration for the puppetmaster.
