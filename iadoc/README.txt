This is iadoc, a package for LaTeX which is used to make documents with
annotations of compliance with information assurance (IA) requirements.

For example, United States Department of Defense Instruction 8500.2
<http://www.dtic.mil/whs/directives/corres/pdf/850002p.pdf> contains about 150
requirements ("IA controls") which apply to automated information systems like
servers and networks. Those inside the Department who want to set up a new
system must write documents showing how the system complies with the
requirements, so that administrators will know how to configure it, and
auditors can satisfy themselves that it complies with the requirements.

One such requirement, DCSS-1, states that "system initialization, shutdown, and
aborts" must be "configured to ensure that the system remains in a secure
state." With iadoc, you can tag the part of your document that talks about
DCSS-1 with \implements{iacontrol}{DCSS-1}, and you will get a margin note and
an index entry. iadoc is geared toward helping notate compliance with hundreds
of requirements written across several discrete documents.

iadoc also helps you format your document in a form suitable inside the
U.S. Department of Defense, by attaching distribution statements, destruction
notices, organization logos, and security labels to it.
