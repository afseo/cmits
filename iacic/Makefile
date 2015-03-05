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
N = iacic

all: $N.pdf $N.sty

%.pdf: %.dtx
	# "Warning: labels may have changed. Run again to get cross-references
	# right"
	pdflatex $^
	pdflatex $^
	makeindex $*.idx
	pdflatex $^

%.sty: %.ins %.dtx
	pdflatex $<

clean:
	rm -f $N.pdf
	rm -f $N.sty
	rm -f *.aux
	rm -f *.log
	rm -f *.toc
	rm -f *.out
	rm -f *.idx *.ind *.ilg
	rm -f *.bbl *.blg
	rm -f *.glo
	rm -rf dist


# These are usual locations, given a prefix. See below for how we set the
# prefix. Note that these will likely be overridden by values given on the
# command line if this makefile is run from a package.
datadir = $(prefix)/share
docdir = $(prefix)/share/doc

# Anyone wishing to put these files in a package (which is the only way I'll
# ever install it systemwide) will supply prefix=... on the make command line.
# So we check if it is set.
ifeq ($(prefix),)
# Not set. Probably a user has typed "make install". Prepare to install into
# the home directory.
LATEX = $(HOME)/texmf/tex/latex
prefix = $(HOME)/.local
else
# We're building a package.
LATEX = $(datadir)/texmf/tex/latex
endif

install: $N.pdf $N.sty
	mkdir -p $(DESTDIR)$(LATEX)/$N
	cp $N.sty $(DESTDIR)$(LATEX)/$N/
	mkdir -p $(DESTDIR)$(docdir)/$N
	cp $N.pdf $(DESTDIR)$(docdir)/$N

dist: $N.pdf $N.sty
	rm -rf dist
	mkdir -p dist/$N
	cp README.txt $N.dtx $N.ins $N.sty $N.pdf dist/$N
	cd dist; zip -r $N.zip $N



###### Food for GNU make
# Don't run in parallel (see documentation about -j option)
.NOTPARALLEL:
# These targets are not actually files
.PHONY: all clean install dist
