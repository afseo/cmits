This is iacic, a horrible hack for LaTeX which is used in concert with the
iadoc package to make documents with annotations of compliance with information
assurance (IA) requirements. "cic" stands for Controls in Contents, and when
you include this package, some notations of compliance are added to section
names as seen in the table of contents of the final document.

For example, United States Department of Defense Instruction 8500.2
<http://www.dtic.mil/whs/directives/corres/pdf/850002p.pdf> contains about 150
requirements ("IA controls") which apply to automated information systems like
servers and networks. Those inside the Department who want to set up a new
system must write documents showing how the system complies with the
requirements, so that administrators will know how to configure it, and
auditors can satisfy themselves that it complies with the requirements.

One such requirement, DCSS-1, states that "system initialization, shutdown, and
aborts" must be "configured to ensure that the system remains in a secure
state." If you write a section \section{State Changes}, which is numbered 2.2
when the document is built, and you use iadoc to notate in your text that you
comply with DCSS-1, like \implements{iacontrol}{DCSS-1}, and you have a table
of contents, the entry for 2.2 will look like "2.2 State Changes---DCSS-1."

Because of the obscene macro hackery involved, it doesn't work if you have any
macros inside your section titles, like \texttt or \emph.
