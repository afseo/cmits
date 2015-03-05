-----------------------------------------------------------
Configuration Management for Information Technology Systems
-----------------------------------------------------------

This is a toolset that makes it easier for network administrators to configure
IT systems in compliance with U.S. Department of Defense requirements, and to
document that compliance as automatically as possible, at several levels of
detail.

CMITS contains many Puppet modules that implement portions of compliance with
about 1000 requirements from nine DoD-level policy documents. These modules
make it easier for administrators to construct a complete Puppet `manifest`
which tells IT systems how to configure themselves in a compliant fashion.
("Puppet is IT automation software that helps system administrators manage
infrastructure throughout its lifecycle"
<http://puppetlabs.com/puppet/what-is-puppet/>.)

CMITS also contains scripts and extensions necessary to create a unified policy
document, which lays out in complete detail how systems are configured using
Puppet, and offers a single place to document IT-related processes, especially
those necessary for compliance. The scripts and extensions also create
automatic summaries, cross-references and indices, so that auditors can easily
find assertions about compliance.


Getting started
---------------

First, look at the cmits-example.pdf file in the build-products folder. This is
an example of a unified policy document that CMITS can build.

Try building your own copy of the document. You may need to install some
software before you can do so. See the
cmits-example/unified-policy-document/README.txt and the
build-products/README.txt.

To get your own hosts configuring themselves according to the policy you see,
you'll need to obtain Puppet, likely set up a puppetmaster, and write manifests
that use the modules given to configure your hosts, or nodes. For directions on
these things, check out the resources provided by Puppet Labs
<http://puppetlabs.com>.
