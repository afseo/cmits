This directory contains files which any CMITS policy document, no matter what
it says, may need to include: the LaTeX machinery of CMITS, if you will.

Why isn't all of this in a LaTeX package? It's so that you can easily override
it. Just make a cmits subdirectory in your unified-policy-document directory,
copy one or more of these files there and change them. LaTeX pays attention to
the TEXINPUTS environment variable as a list of places to look for files that
are being included, and the sourapples build system always puts '.', the
current directory, on TEXINPUTS before the latex-unclass directory. And '.'
when we are building is the unified-policy-document directory. So when
main.tex tries to \include{cmits/bla.tex}, LaTeX will pick up your customized
cmits/bla.tex in unified-policy-document, not the more general
../latex-unclass/cmits/bla.tex.
