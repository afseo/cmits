``shaney`` is a script that takes one or more files containing Puppet language
with LaTeX source written in comments, and renders a file containing LaTeX
source with Puppet language written in LaTeX verbatim tags. This file can be
used as part of a LaTeX document, which can be typeset into a PDF file.

``shaney`` knows a little Puppet syntax, so that it can, for example, add an
index entry for each class in the output document. 

``shaney`` also auto-summarizes compliance with DoDI 8500.2 IA controls, by
looking for compliance posture tags defined by the skiadoc LaTeX style.
